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

my $unz = IO::Uncompress::Unzip->new("$FindBin::Bin/user_relation.zip") 
                                                        or die "unzip: $!";  

my $cnt = 0;
my $flds = [];
my $table = "relations";
my $columns = "first_id,second_id";
my $sql = sprintf "insert into %s (%s) values ", $table, $columns;
my @sqls;
while(my $line = $unz->getline) {
    $line =~ s/\n//;
    push @{$flds}, join ",", split " ", $line;

    if (++$cnt == 700_000) {
        $cnt = 0;
        my $sth = $sql.(join ",", map {"(".$_.")"} @{$flds});
        $dbh->quote($sth);
        $dbh->do($sth);
        $flds = [];
    }
}
if (scalar @{$flds}){
        my $snt = $sql.(join ",", map {"(".$_.")"} @{$flds});
        $dbh->quote($snt);
        $dbh->do($snt);
        say "completed...";
}
