package ConfApi;

use FindBin; 
use DDP;
use YAML::Tiny;

sub new {
    my ($class, %prms) = @_;
    bless \%prms, $class;
}
sub Get_conf {
    my $self = shift;
    my $conf = YAML::Tiny->read( "$FindBin::Bin/../conf/config.yml" )->[0];

    return $conf;
}

1;
