#!/usr/bin/env perl

use 5.016;
use strict;
use warnings;
use integer;
use Cwd;
use experimental 'smartmatch';
use constant TMB;

if (@ARGV != 1) {
   die sprintf("Bad arguments \n\nUsage: %s [number] ...\n",
                                    Cwd::abs_path($0));
} else {
   die "Not a natural number ...\n" unless ($ARGV[0] =~ m/^[1-9]+\d*$/);
}
die "Support is only up to a billion ...\n" if (length($ARGV[0])>10);

my $apndx = '';

sub _endMB {
   my @mas;
   if ($_[0] == 1) {
      return '';
   }
   @mas = qw(2 3 4);
   if ($_[0] ~~ @mas) {
      return 'а';
   }
   else {
      return 'ов';
   }
}

sub _endT {
   my @mas = qw(0 5 6 7 8 9);
   if ($_[0] ~~ @mas) {
      return '';
   }
   if ($_[0] == 1) {
      return 'а';
   }
   else {
      return 'и';
   }
}

my %TMB = (
   0 => '',
   1 => ' тысяч',
   2 => ' миллион',
   3 => ' миллиард',
);

my %hundreds = (
   0 => '',
   1 => ' сто',
   2 => ' двести',
   3 => ' триста',
   4 => ' четыреста',
   5 => ' пятьсот',
   6 => ' шестьсот',
   7 => ' семьсот',
   8 => ' восемьсот',
   9 => ' девятьсот',
);

my %tens = (
   0 => '',
   1 => ' десять',
   2 => ' двадцать',
   3 => ' тридцать',
   4 => ' сорок',
   5 => ' пятьдесят',
   6 => ' шестьдесят',
   7 => ' семьдесят',
   8 => ' восемьдесят',
   9 => ' девяносто',
);

my %digits = (
   0 => '',
   1 => ' один',
   2 => ' два',
   3 => ' три',
   4 => ' четыре',
   5 => ' пять',
   6 => ' шесть',
   7 => ' семь',
   8 => ' восемь',
   9 => ' девять',
);

my %digitsTh = (
   0 => '',
   1 => ' одна',
   2 => ' две',
   3 => ' три',
   4 => ' четыре',
   5 => ' пять',
   6 => ' шесть',
   7 => ' семь',
   8 => ' восемь',
   9 => ' девять',
);

sub _evhtd {
   my ($h, $t, $d);
   $h = $_[0]/100;
   $t = $_[0]/10 - $h*10;
   $d = $_[0] - $t*10 - $h*100;

   return ($h, $t, $d);
}

sub _append {
   my $intr;
   my $len = length($_[0]);
   my ($h, $t, $d);

   if ($len > 9) {
      $intr = sprintf("%03d", substr($_[0],0,$len-9));
      substr($_[0],0,$len-9) = "";
      ($h, $t, $d) = _evhtd($intr);

      $apndx = $apndx . $hundreds{$h} . $tens{$t} .
                        $digits{$d} . $TMB{3} . _endMB($d) . " ";
      $len = length($_[0]);
   }
   if ($len > 6 && substr($_[0],0,$len-6) != 0) {
      $intr = sprintf("%03d", substr($_[0],0,$len-6));
      substr($_[0],0,$len-6) = "";
      ($h, $t, $d) = _evhtd($intr);

      $apndx = $apndx . $hundreds{$h} . $tens{$t} .
                        $digits{$d} . $TMB{2} . _endMB($d) . " ";
      $len = length($_[0]);
   }
   if ($len > 3 && substr($_[0],0,$len-3) != 0) {
      $intr = sprintf("%03d", substr($_[0],0,$len-3));
      substr($_[0],0,$len-3) = "";
      ($h, $t, $d) = _evhtd($intr);

      $apndx = $apndx . $hundreds{$h} . $tens{$t} .
                        $digitsTh{$d} . $TMB{1} . _endT($d) . " ";
      $len = length($_[0]);
   }
   $intr = sprintf("%03d", substr($_[0],0,$len));
   substr($_[0],0,$len) = "";
   ($h, $t, $d) = _evhtd($intr);

   $apndx = $apndx . $hundreds{$h} . $tens{$t} .
                     $digits{$d};
   return substr($apndx,1) . "\n";
}

print _append ($ARGV[0]);
