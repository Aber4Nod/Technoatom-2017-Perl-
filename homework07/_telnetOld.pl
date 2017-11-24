#!/usr/bin/env perl

use 5.016;
use Socket;
use threads;
use threads::shared;

$| = 1;
my ($host, $port) = @ARGV;
my $proto = getprotobyname('tcp');
my $ip = inet_aton($host);
my $paddr = sockaddr_in($port, $ip);
socket(SOCKET, AF_INET, SOCK_STREAM, $proto) or die "socket: $!";

connect(SOCKET, $paddr) or die "connect: $!";
my ($thr, $thr1) = (threads->create(sub { print $_ while (<SOCKET>) }),
                    threads->create(sub { send SOCKET, $_, 0 while (<STDIN>)}));
$thr->join();
$thr1->join();
