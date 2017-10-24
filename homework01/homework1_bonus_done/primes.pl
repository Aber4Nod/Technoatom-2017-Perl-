#!/usr/bin/env perl

use warnings;
use Cwd;

if (@ARGV != 1) {
   die sprintf("Bad arguments \n\nUsage: %s [number] ...\n",
                                    Cwd::abs_path($0));
} else {
   die "Not a natural number ...\n" unless ($ARGV[0] =~ m/^[1-9]+\d*$/);
}

=naivePrime

sub _naivePrime {
   for (my $c=2; $c*$c <= $_[0]; $c++) {
      if ($_[0]%$c==0) {
         return 0;
      }
   }
   return 1;
}

for (my $c=2;$c<$ARGV[0];$c++) {
   if (_naivePrime($c)) {
      print $c . " ";
   }
}

=cut

sub _EratSieve {
   my @S = (1) x $_[0];
   $S[0] = 0;
   
   for (my $c=2; $c*$c<=$_[0]; $c++) {
      if ($S[$c-1]) {
         for (my $i=$c*$c; $i<=$_[0]; $i+=$c) {
            $S[$i-1]=0;
         }
      }
   }
   return @S;
}

my @ret = _EratSieve($ARGV[0]);

for (my $c=2; $c<=$ARGV[0]; $c++) {
   if ($ret[$c-1]){
      print $c . " ";
   }
}


