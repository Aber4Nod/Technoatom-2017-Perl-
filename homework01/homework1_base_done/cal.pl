#!/usr/bin/env perl
  use warnings;
  use Time::Local;
  use Cwd;
  
  my @daysYear = qw(31 28 31 30 31 30 31 31 30 31 30 31);
  my $year = 2017;
  
  if (@ARGV == 1) {
    die "Month must be set by integer ...\n"  if $ARGV[0] =~ m/\D/ ;
    die "Month is out of range ...\n" if ($ARGV[0]  < 1 || $ARGV[0] > 12);
  } else {
    die sprintf("Bad arguments \n\nUsage: %s [month] ...\n",
                                    Cwd::abs_path($0)) if @ARGV != 0;
  }
  
  sub _cal {
    my @rMonth;
    my $first; my @daysMonth; my @fWeek;
    my $month = $_[0] ? $_[0] : (localtime)[4] + 1;
    $first = (localtime(timelocal(0, 0, 0, 1, $month -1, $year-1900)))[6];
    @daysMonth = (1 .. _days($month));
    @fWeek = (undef) x 7;
    @fWeek[$first .. 6] = splice(@daysMonth, 0, 6 - $first + 1);
    @rMonth = (\@fWeek);
    while (my @curWeek = splice(@daysMonth, 0, 7)) {
      push @rMonth, \@curWeek;
    }
    return @rMonth;
  }
  
  sub _days {
    return $daysYear[$_[0] - 1];
  }
  
  my @months = qw/January February March April May June July August
                  September October November December/;
  my $mon = shift || (localtime)[4] + 1;
  my @month = _cal($mon);
  
  print "   $months[$mon -1] $year\n";
  print "Su Mo Tu We Th Fr Sa\n";
  foreach (@month) {
    print map { $_ ? sprintf("%2d ", $_ ): '   ' } @$_;
    print "\n";
  }