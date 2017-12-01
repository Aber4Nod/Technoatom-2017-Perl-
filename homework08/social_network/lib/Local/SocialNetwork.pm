package Local::SocialNetwork;

use DDP;
use List::Util qw(any);
use 5.016;

use JSON::XS;
use Local::ConfApi;
use Local::DBApi;

=encoding utf8

=head1 NAME

Local::SocialNetwork - social network user information queries interface

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub new {
    my ($class, $prms) = @_;
    my $confReader = Local::ConfApi->new($prms->{config});
    my $conf = $confReader->GET_conf(); 
    my $database = $conf->{database};

    my $dbCustom = Local::DBApi->new(database => $database);
    $prms->{'dbC'} = $dbCustom;
    $prms->{'JSON'} = JSON::XS->new->pretty;
    bless $prms, $class;
}

sub CHECK_id {
    my ($self, @ids) = @_;
    my $dbC = $self->{'dbC'};
    my $max_id = $dbC->SELECT_max_id;    
    return 0  if any { $_ > $max_id } @ids; 
    return 1;
} 

sub GET_names_by_id {
    my ($self, $ids) = @_;
    my $dbC = $self->{'dbC'};
    die "no such id" if !$self->CHECK_id(@$ids);
   
    warn "Max sql var lim"  if (scalar $ids > 150_000);
    my $arrref = $dbC->SELECT_names_by_ids($ids);
    return $self->{'JSON'}->encode($arrref);
}

sub GET_singles {
    my ($self) = shift;
    my $dbC = $self->{'dbC'};
    return $dbC->SELECT_singles;
}

sub GET_friends_mutual {
    my ($self, $id0, $id1) = @_;
    die "id not valid" if !$self->CHECK_id($id0, $id1);
    my $dbC = $self->{'dbC'};     
    my $ret = $dbC->SELECT_friends_mutual($id0, $id1);
    my $retNames = $dbC->SELECT_names_by_ids($ret);
    return $self->{'JSON'}->encode($retNames);
}

sub GET_friends_by_ids {
    my ($self, $ids) = @_;
    # if (!$self->CHECK_id(@{$ids})) {
    #     p $ids;
    #     die "not valid id";
    # }
    die "not valid id" if !$self->CHECK_id(@{$ids});
    my $dbC = $self->{'dbC'};
    return $dbC->SELECT_friends_by_ids($ids);
}

sub GET_number_handshakes {
    my ($self, $id0, $id1) = @_;
    my $dbC = $self->{'dbC'};
    die "<2 id entered" unless ($id0 && $id1);
    return $self->{'JSON'}->encode([0]) if $id0 == $id1;

    die "not valid id" if !$self->CHECK_id($id0, $id1);
    
    my $singles = $self->GET_singles;
    return "single intered" if any {$_ == $id0 or $_ == $id1} @{$singles};

    my $upper = $dbC->SELECT_max_id - scalar @{$singles};
    my ($seen, $friends) = {};

    push @{$friends}, $id0;
    my ($ret, $cnt) = (0,1);

    #naive Dijkstra's algorithm
    while (scalar keys %{$seen} < $upper && !$ret || !scalar @{$friends}){
        @{$friends} = grep {!exists $seen->{$_}} @{$self->GET_friends_by_ids($friends)};
        foreach my $fr (@$friends) {
            $seen->{$fr} = $cnt;
            if ($id1 == $fr) {
                $ret = $cnt;
                last;
            }
        }
        $cnt++;
    }
    $ret = $ret ? {"number hsk" => $ret} : ["no hsk"];
    return $self->{'JSON'}->encode($ret);
}

1;
