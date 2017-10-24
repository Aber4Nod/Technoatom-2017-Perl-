#!/usr/bin/env perl

use warnings;
use Time::Local;
use Cwd;

if (@ARGV != 0) {
   die sprintf("Bad arguments \n\nUsage: %s ...\n",
                                    Cwd::abs_path($0));
}

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
					localtime(time);
$wday+=7 unless $wday;

my $secondsHL = 3600 - $min*60 - $sec;
my $secondsDL = 24*3600 - $hour*3600 - $min*60 - $sec;
my $secondsWL = (7-$wday)*24*3600 + $secondsDL;

print "HLeft: " . $secondsHL . "\nDLeft: " . $secondsDL . "\nWLeft: " . $secondsWL;
