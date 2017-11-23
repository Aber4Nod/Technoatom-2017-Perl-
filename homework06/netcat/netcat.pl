use Getopt::Long;
use IO::Socket;

my ($addr, $port, $proto) = ($ARGV[0], $ARGV[1]);

GetOptions ('p=s' => \$proto,
            );

die "invalid proto" if ($proto cmp 'tcp' && $proto cmp 'udp');
my $socket = IO::Socket::INET->new(
PeerAddr => $addr,
PeerPort => $port,
Proto => $proto,
) or die "Can't connect to $addr $!$/";

while (<STDIN>) {
   print $socket $_ or die $!;
}

exit ($socket);
