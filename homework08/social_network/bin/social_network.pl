#!/usr/bin/env perl

use 5.016;
use DDP;
use Getopt::Long;
use FindBin;

use lib "$FindBin::Bin/../lib";
use Local::SocialNetwork;

my $cmd = shift;
my (@users, @userName) = ();
GetOptions ("userName=s{2}" => \@userName,
            "user=i" => \@users,
            );
my $prms = {
    config => "config.yml",
};
my $obj = Local::SocialNetwork->new($prms);

if ($cmd eq 'nofriends') {
    my $singles = $obj->GET_singles();
    say $obj->GET_names_by_id($singles);
} elsif ($cmd eq 'friends') {
    die "number of users < 2" if scalar @users < 2;
    my $ret = $obj->GET_friends_mutual(@users[0,1]);
    p $ret;
} elsif ($cmd eq 'num_handshakes') {
    die "number of users < 2" if scalar(@users) < 2;        
    my $ret = $obj->GET_number_handshakes(@users[0,1]);
    p $ret;
} else {
    say "command fault";
}
