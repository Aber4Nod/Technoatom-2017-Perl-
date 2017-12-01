package Local::ConfApi;

use FindBin; 
use List::Util;
use YAML::Tiny;
use DDP;

sub new {
    my ($class, $prms) = @_;
    my $self = { 
        config => $prms,
    };
    bless $self, $class;
}
sub GET_conf {
    $self = shift;
    my $obj = YAML::Tiny->read("$FindBin::Bin/../conf/$self->{config}")->[0];
    return $obj;
}

1;
