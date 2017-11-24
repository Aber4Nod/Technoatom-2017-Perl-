#!/usr/bin/env perl

use 5.016;
use AnyEvent::HTTP;
use URI;
use DDP;
use Getopt::Long qw(:config no_ignore_case bundling);
use Data::Dumper;
my ($N, $r, $l, $L, $S) = '';

GetOptions ('N=i' => \$N,
            'r' => \$r,
            'l=i' => \$l,
            'L' => \$L,
            'S' => \$S,
        );
my %hosts;
my @queue = @ARGV;
my (%seen, %level); 
my $cv = AnyEvent->condvar();
$AnyEvent::HTTP::MAX_PER_HOST = my $upper = $N ? $N : 1;
my $running = 0;
my $depth = defined $l ? $l : 5;
my $bufCounter=0;

for (@queue){
    my $_uri = URI->new($_)->host;
    $hosts{$_uri} = undef;
    mkdir($_uri);
    $level{$_}=0;
}

sub _wget {
    my $curDepth = shift;
	my $uri = shift @queue or return;
	$seen{$uri} = undef;
    if ($level{$uri}>$curDepth){
        $curDepth = $level{$uri};
    }
    my $minLevel = (sort { $a <=> $b } values %level)[0];

    if ($minLevel < $curDepth) {
        unshift @queue, $uri;
        $bufCounter++;
        return;
    }
    $cv->begin;

    say "$minLevel\t$curDepth";
	$running++;
    http_request
    HEAD => $uri,
    sub {
        my ($body,$hdr) = @_;
        if ($hdr->{Status} != 200 || $hdr->{"content-type"} !~ m/^text\/html.*/) {
            $bufCounter=0;
            $running--;
            $seen{$uri} = $hdr->{Status};
            delete $level{$uri};
            $cv->end;
            return;
        }
        http_request
        GET => $uri,
        sub {
            my ($body,$hdr) = @_;
            say "Loaded: $uri";
            
            if ($S){
                say '  HTTP/' . $hdr->{HTTPVersion} . ' ' . $hdr->{Status} . ' ' .
                                                $hdr->{Reason};
                say '  Date: ' . $hdr->{date};
                say '  Server: ' . $hdr->{server};  
                say '  Accept-Ranges: ' . $hdr->{"accept-ranges"};
                say '  Connection: ' . $hdr->{connection};
                say '  Transfer-Encoding: ' . $hdr->{"transfer-encoding"};
                say '  Content-Type: ' . $hdr->{"content-type"};
            }
            $bufCounter=0;
            $running--;
            my $hostOt = URI->new($uri)->host;

            my $_nuri = $uri =~ s/^https?:\/\/$hostOt\/?//r;
            $_nuri =~ s/\//:/sg;
            $_nuri = "index.html" unless $_nuri;
        
            chdir($hostOt) or die "Change: $!";
            open(my $fh, '>', "$_nuri") or die "Create: $!";
            syswrite($fh, $body, length($body));
            close($fh);
            chdir("..");

            $seen{$uri} = $hdr->{Status};
            if ($r && $hdr->{Status} == 200) {
                if ($curDepth < $depth) {
                    $body =~ s/<!--.*?-->//gs;
                    my @href;
                    @href = $body =~ m{<a[^>]*href="([^"#]+)"}sig;
                    for my $href (@href) {
                        my $new;
                        if ($L){
                            next if $href =~ /^https?:/;
                        } 
                        $new = URI->new_abs($href, $hdr->{URL});
                        next if $new !~ /^https?:/;
                        next unless exists $hosts{$new->host};
                        next if exists $seen{$new};
                        next if exists $level{$new};
                        push @queue, $new;
                        $level{$new}=$level{$uri}+1; 
                    }
                }
            }
            delete $level{$uri};
            while (@queue and $bufCounter < $upper and $running < $upper) {
                _wget($curDepth);
            }
            $cv->end;
        };
    };
};

_wget(0);

$cv->recv;
say "Completed...";
