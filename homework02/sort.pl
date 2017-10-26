use strict;
use Getopt::Long;

my ($num, $rev, $uniq, $month, $col, $hsp, $check, $tsuf) = '';
my %add;
my $mth;
my @mth = qw( Jan January Feb February Mar March Apr April May Jun June Jul July Aug
                        August Sep September Oct October Nov November Dec December);
@{$mth}{@mth} = (0..$#mth);

GetOptions ('k=i' => \$col,
            'n' => \$num,
            'r' => \$rev,
            'u' => \$uniq,
            'M' => \$month,
            'b' => \$hsp,
            'c' => \$check,
            'h' => \$tsuf,
            );

sub _sortC {
  my @cData; my @arrData; my @rData; my $count; my @res; my $countArr; my @mthData; my @mthArr;

  while (<STDIN>) {
    my @a;

    if ($_[0] != -1) {
      if ($hsp) {
        @a = $_ =~ /^\s*(?:(\s*\S*)\s\K){$_[0]}/
      } else {
        @a = $_ =~ /^(?:(\s*\S*)\s\K){$_[0]}/
      }
    } else {
        if ($hsp) {
          @a = $_ =~ /^\s*(.*){1}/;
        } else {
          @a = $_;
        }
    }
    if ($month) {
      if (exists $mth->{$a[0]}) {
        $mthArr[$countArr]=$a[0];
        $mthData[$countArr++] = $_;
      } else {
        $cData[$count] = $a[0];
        $arrData[$count++] = $_;
      }
    } else {
      $cData[$count] = $a[0];
      $arrData[$count++] = $_;
    }
  }
  if ($check) {
    for my $i (0 .. $#cData-1) {
      if ($num) {
        if (($cData[$i] <=> $cData[$i+1]) == 1) {
          print ("sort.pl: -:" . $i+1 . ": disorder: " . $arrData[$i]);
          return;
        }
      } elsif (($cData[$i] cmp $cData[$i+1]) == 1) {
           print ("sort.pl: -:" . ($i+1) . ": disorder: " . $arrData[$i]);
           return;
      }
    }

    for my $i (0 .. $#mthArr-1) {
      if ($num) {
        if (($mthArr[$i] <=> $mthArr[$i+1]) == 1) {
          print ("sort.pl: -:" . $i+1 . ": disorder: " . $mthData[$i]);
          return;
        }
      } elsif (($mthArr[$i] cmp $mthArr[$i+1]) == 1) {
           print ("sort.pl: -:" . $i+1 . ": disorder: " . $mthData[$i]);
           return;
      }
    }

    return;
  }

  if ($tsuf) {
    my %suffixes = (
       K => "1000",
       M => "1000000",
       G => "1000000000",
       T => "1000000000000",
       P => "1000000000000000",
       E => "1000000000000000000",
       Z => "1000000000000000000000",
       Y => "1000000000000000000000000",
    );
    my $buf;
    foreach (@cData) {
      $buf = substr($_,-1,1);
      if ($suffixes{$buf}) {
        $_ = $_ * $suffixes{$buf};
      }
    }
    $num = 1;
  }
  my $index; my $pat; $count = 0;
  @rData = @cData;
  for ($num ? sort _numSort @cData : sort @cData) {
    $pat = $_;

    for my $i (0 .. $#rData) {
      if ($rData[$i] eq $pat) {
        $index = $i;
        $res[$count++] = $arrData[$index];
        last;
      }
    }
    splice @rData, $index, 1;
    splice @arrData, $index, 1;
  }

  @rData = @mthArr;
  for (sort _monthSort @mthArr) {
    $pat = $_;

    for my $i (0 .. $#rData) {
      if ($rData[$i] eq $pat) {
        $index = $i;
        $res[$count++] = $mthData[$index];
        last;
      }
    }
    splice @rData, $index, 1;
    splice @mthData, $index, 1;
  }

  if ($uniq) {
    my %unique;
    @res = grep { !$unique{$_}++ } @res;
  }
  if ($rev) {
    print reverse @res;
  } else {
    print @res;
  }
}

sub _monthSort {
    $mth->{$a} <=> $mth->{$b};
}

sub _numSort {
  $a <=> $b;
}

$col ? _sortC($col) : _sortC(-1);
