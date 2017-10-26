#!/usr/bin/env perl

use warnings;
use integer;
use Cwd;

if (@ARGV != 1) {
   die sprintf("Bad arguments \n\nUsage: %s [number] ...\n",
                                    Cwd::abs_path($0));
} else {
   die "Not natural number ...\n" unless ($ARGV[0] =~ m/^[1-9]+\d*$/)  
}

=naiveFact
sub _naiveFact {
   return $_[0] ? $_[0]*_naiveFact($_[0]-1) : 1;
}
=cut

sub _MultTr {
   if ($_[0] > $_[1]) {
      return 1;
   }
   if ($_[0] == $_[1]) {
      return $_[0];
   }
   if ($_[1] - $_[0] == 1) {
      return $_[0]*$_[1];
   }
   my $mean = ($_[0] + $_[1])/2;
   return _MultTr($_[0], $mean) * _MultTr($mean + 1, $_[1]);
}

my @buf = qw(1 2);

if ($ARGV[0] ~~ @buf) {
   print $ARGV[0];
} else {
   print _MultTr(2, $ARGV[0]);
   #print _naiveFact($ARGV[0]);
}