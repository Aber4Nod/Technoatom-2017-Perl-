package Local::DBApi;

use 5.016;

use DDP;
use DBI;
use FindBin;

sub new {
    my ($class, %prms) = @_;
    die "No database found" if !exists $prms{'database'};
    my $database = "$FindBin::Bin/../etc/".$prms{'database'};
    die "db file not exists" if ! -e $database;
    $prms{'database'} = $database;
    my ($userid, $password) = '';
    my $dbh = DBI->connect("dbi:SQLite:dbname=$database", $userid, $password,
                                { RaiseError => 1 }) or die "Connect error";
    $dbh->do('PRAGMA foreign_keys = ON;');
    $prms{'dbh'} = $dbh;
    bless \%prms, $class;
}

sub SELECT_singles {
    my ($self) = shift;
    my $dbh = $self->{'dbh'};

    my $ret = $dbh->selectall_arrayref(
        "SELECT id FROM users EXCEPT SELECT DISTINCT first_id FROM relations ". 
        "EXCEPT SELECT DISTINCT second_id FROM relations;"
    );
    return [map {$_->[0]} @{$ret}];
}

sub SELECT_max_id {
    my ($self) = @_;
    my $dbh = $self->{'dbh'};
    my $cnt = $dbh->selectall_arrayref("SELECT id FROM users ORDER BY id DESC LIMIT 1;" );
    return $cnt->[0]->[0];
}

sub SELECT_friends_by_ids {
    my ($self, $ids) = @_;
    my $dbh = $self->{'dbh'};

    my $sql = "SELECT DISTINCT first_id FROM relations WHERE second_id IN (".
    (join ", ", ('?') x @{$ids}).") ".
    "UNION SELECT DISTINCT second_id FROM relations WHERE first_id IN (".
    (join ", ", ('?') x @{$ids}).")";

    my $ret = $dbh->selectall_arrayref($sql, {}, @{$ids}, @{$ids});
    return [map {$_->[0]} @{$ret}];
}

sub SELECT_names_by_ids {
    my ($self, $ids) = @_;

    my $dbh = $self->{'dbh'};
    my $sql = "SELECT * FROM users WHERE id IN (". (join ", ", ('?') x @{$ids}).") ";
    my $ret = $dbh->selectall_arrayref($sql, {Slice => {}}, @{$ids});
    return $ret;
}

sub SELECT_friends_mutual {
    my ($self, $id0, $id1) = @_;
    my $sql = 
    "SELECT * FROM (SELECT DISTINCT first_id FROM relations WHERE second_id == ? ".
    "UNION SELECT DISTINCT second_id FROM relations WHERE first_id == ?) ".
    "INTERSECT ".
    "SELECT * FROM (SELECT DISTINCT first_id FROM relations WHERE second_id == ? ".
    "UNION SELECT DISTINCT second_id FROM relations WHERE first_id == ?)";
    my $dbh = $self->{'dbh'};
    my $ret = $dbh->selectall_arrayref( $sql, {}, $id0, $id0, $id1, $id1 );
    return  [map {$_->[0]} @{$ret}];
}

1;
