use 5.016;
use strict;
use Getopt::Long;
use Cwd;

my ($f, $d, $s) = '';

GetOptions ('f=s' => \$f,
            'd=s' => \$d,
            's' => \$s,
            );

unless ($d) {
  $d = "\t";
}

my @f = split /,/, $f;
my $length;

sub _makeInt {
    if ($_[0]&&$_[1]) {
      return ($_[0]..$_[1]);
    } elsif ($_[0]) {
      return ($_[0]..$length);
    } else {
      return (0..$_[1]);
    }
}

sub _makeList {
  foreach my $elem (@f) {
    $elem =~ /(\d*)(-?)(\d*)/;
    if ($2) {
      my @pair = ($1,$3);
      unless (split //, @pair) {
        die sprintf("%s: invalid range with no endpoint: -",
                                   Cwd::abs_path($0));
      }
      $elem = join ',', _makeInt(@pair);
    }
  }
  @f = do {my %h; grep { !$h{$_}++} sort {$a <=> $b} split /,/, join ',', @f};
  return @f;
}

while (<STDIN>) {
  chomp($_);
  my $buf = [split(/\Q$d/, $_)];
  $length = @$buf;
  if (@$buf > 1 || !$d) {
    my @res = _makeList();
    foreach (@res) {
      print "@{$buf}[$_-1]";
      print $d if ($length > $_);
    }
    print $/;
  } elsif (!$s) {
    print $_ . $/;
  }
}
