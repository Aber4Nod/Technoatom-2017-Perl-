#!/usr/bin/env perl

use DBI;
use strict;

my $driver   = "SQLite";
my $database = "schema.db";
my $dsn = "DBI:$driver:dbname=$database";
my $userid = "";
my $password = "";
my $dbh = DBI->connect($dsn, $userid, $password, { RaiseError => 1 })
   							or die $DBI::errstr;

my $stmt = qq(create table users(
        id integer primary key not null,
        first_name varchar(64) not null,
        last_name varchar(64) not null
    ););

my $rv = $dbh->do($stmt);
if($rv < 0) {
   print $DBI::errstr;
} else {
   print "users table created$/";
}

$stmt = qq(create table relations(
        first_id integer not null,
        second_id integer not null,
        foreign key (first_id) references users(id),
        foreign key (second_id) references users(id)
	););

$rv = $dbh->do($stmt);
if($rv < 0) {
   print $DBI::errstr;
} else {
   print "relations table created$/";
}

$dbh->disconnect();
