#!/usr/bin/env perl

use 5.016;
use DDP;
use DBI;
use FindBin;
use IO::Uncompress::Unzip;

my $database = "$FindBin::Bin/schema.db";
my $userid = "";
my $password = "";
my $dbh = DBI->connect("dbi:SQLite:dbname=$database", $userid, $password, 
                                                        { RaiseError => 1 }) or die;

my $unz = IO::Uncompress::Unzip->new( "$FindBin::Bin/user.zip")  
                                                        or die "unzip: $!" ;  
my $cnt = 0;
my $flds = [];
my $table = "users";
my $columns = "first_name, last_name";
my $sql = sprintf "insert into %s (%s) values ", $table, $columns;

while(my $line = $unz->getline) {
    $line =~ s/\n//;
    push @{$flds}, join ",",  map {"\"".$_."\""} @{[split " ", $line]}[1,2];
    if (++$cnt == 700_000) {
        $cnt = 0;
        my $snt = $sql.(join ",", map {"(".$_.")"} @{$flds});
        $dbh->quote($snt);
        $dbh->do($snt);
        $flds = [];
    }
}
$sql = sprintf "insert into %s (%s) values ", $table, $columns;

if (scalar @{$flds}){    
        my $snt = $sql.(join ", ", map {"(".$_.")"} @{$flds});
        $dbh->quote($snt);
        $dbh->do($snt);    
        say "completed...";
}
