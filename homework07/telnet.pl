#!/usr/bin/env perl

use 5.016;
use Socket;
use AnyEvent;
use AnyEvent::Handle qw();
use AnyEvent::Socket qw(tcp_connect);

$| = 1;
my ($host, $port) = @ARGV;
my $ip = inet_aton($host);
my $handle;

_tlnt($host,$port);

sub _tlnt {
    my ($host, $port) = @_;
    tcp_connect($host, $port, sub{
            my ($sock) = @_ or die "Connect: $!";
            $handle = AnyEvent::Handle->new(
                fh => $sock,
                on_eof => sub {
                    $handle->destroy();
                },
                on_read => sub {
                    my ($handle) = @_;
                    print $handle->rbuf();
                },
            );
        });
}

my $r = AE::io \*STDIN, 0, sub {
    my $line = <STDIN>;
    if ($handle) {
       $handle->push_write($line);    
    }
};

AE::cv->recv;
