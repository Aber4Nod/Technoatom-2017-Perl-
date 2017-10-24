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

=comment
Считаем, что последовательность начинается с пары 1 => 0:
1 0
2 1
3 1
4 2
...
=cut

sub _fibonacci {
   my @rMas;
   my @buf = qw(2 3);
   
   if ($_[0] == 1) {
      return 0;
   } elsif ($_[0] ~~ @buf) {
      return 1;
   }
   @rMas = qw(0 1 1);

   while ($_[0] > 3){
      push @rMas, $rMas[-1] + $rMas[-2];
      $_[0]--;
   }
   return $rMas[-1];
}

print _fibonacci($ARGV[0]);
