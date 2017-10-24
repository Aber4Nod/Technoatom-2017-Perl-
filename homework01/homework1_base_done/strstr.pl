#!/usr/bin/env perl

use warnings;
use Cwd;

die sprintf("Bad arguments ...\n\nUsage: %s \"haystack\" \"needle\" ...\n",
				Cwd::abs_path($0)) if @ARGV !=2;
my $indx = index($ARGV[0],$ARGV[1]);

if ($indx == -1) {
   warn "Not found\n";
} else {
   print $indx . "\n" . substr($ARGV[0], $indx);
}