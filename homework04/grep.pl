use 5.016;
use strict;
use Getopt::Long qw(:config no_ignore_case bundling);
use Cwd;

my ($A, $B, $C, $c, $i, $v, $F, $n) = '';

GetOptions ('c!' => \$c,
            'B=i' => \$B,
            'C=i' => \$C,
            'A=i' => \$A,
            'i!' => \$i,
            'v!' => \$v,
            'F!' => \$F,
            'n!' => \$n,
            );
unless (@ARGV) {
  die sprintf("Usage: perl %s [OPTION]... PATTERN ...\n",
                             Cwd::abs_path($0));
}
my $inpLine; my $lineNumber; my $countA; my $totalcount; my $countLines;
while (<STDIN>) {
  my $eq; my $re;
  $countLines++;
  $re = $F ? quotemeta($ARGV[0]) : $ARGV[0];
  $eq = $_ =~ $i ? /$re/ : /$re/i;
  if ($v&&!$eq || !$v&&$eq) {
    if ($c) {
      $totalcount++;
    } elsif ($n) {
      print $inpLine . $countLines . ':' . $_;
    } else {
      print $inpLine . $_;
    }

    if ($B||$C){
      $inpLine = '';
      $lineNumber = 0;
    }
    $countA = $A > $C ? $A : $C;
  } elsif (!$c) {
    if (($A||$C) && $countA-- >0) {
      unless ($c) {
        if ($n) {
          print $countLines . '-' . $_;
        } else {
          print $_;
        }
      }
    } elsif ($B||$C) {
      if ($n) {
        $inpLine = $inpLine . $countLines . '-' . $_;
      } else {
        $inpLine = $inpLine . $_;
      }
      $lineNumber++;
      if ($lineNumber > $B && $lineNumber > $C) {
        $inpLine =~ s{((.*)[\n])}{};
        $lineNumber--;
      }
    }
  }
}
if ($c) {
  print $totalcount;
}
