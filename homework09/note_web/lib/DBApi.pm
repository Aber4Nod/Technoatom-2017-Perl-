package DBApi;

use strict;
use warnings;

use DDP;
use DBI;
use FindBin;

use Encode qw(encode decode);

sub new {
    my ($class, %prms) = @_;
    my $db = "$FindBin::Bin/../data/".$prms{'DataBase'};
    $prms{'DataBase'} = $db;

    my $dbh = DBI->connect("dbi:SQLite:dbname=$db", "","", { RaiseError => 1 }) or die "db connection has occured:\n";
    $dbh->do('PRAGMA foreign_keys = 1;');
    $prms{'dbh'} = $dbh;
    bless \%prms, $class;
}

sub CHECK_user_pswd {
    my ($self, $user, $pswd) = @_;
    my $sth = $self->{'dbh'}->selectrow_arrayref(
            'SELECT COUNT(*) FROM auth WHERE user = (?) and pswd == (?)',
            {},
            $user,
            $pswd
            );

    return $sth->[0];
}

sub ADD_user {
    my ($self, $user, $pswd) = @_;
    my $dbh = $self->{'dbh'};
    return undef if ($self->GET_id($user));

    my $sql = "INSERT INTO auth (user, pswd) VALUES((?), (?));";
    my $sth = $self->{'dbh'}->prepare($sql);
    $sth->execute($user, $pswd);
    return 1;
}

sub ADD_note {
    my ($self, $note_id, $creator_id, $time, $title, $text, $shared_ids) = @_;

    my $sql = 'INSERT INTO notes VALUES (?, ?, ?, ?)';
    my $sth = $self->{'dbh'}->prepare($sql);
    $sth->execute($note_id, $title, $text, time);

    $sql = 'INSERT INTO crnote VALUES (?, ?)';
    $sth = $self->{'dbh'}->prepare($sql);
    $sth->execute($creator_id, $note_id);
    
    my @sqlprepared;
    foreach (@{$shared_ids}) {
        my $shared_id = $self->GET_id($_);
        if ($shared_id && $self->CHECK_userid($shared_id)
                                              && $creator_id != $shared_id) {
            push @sqlprepared, ($shared_id, $note_id, $creator_id);
        }
    }
    if(my $num = @sqlprepared/3) {
        $sql = 'INSERT INTO shnotes VALUES '.(join ',', ("(?, ?, ?)") x ($num));
        $sth = $self->{'dbh'}->prepare($sql);
        $sth->execute(@sqlprepared);
    }
}

sub GET_notes {
    my ($self, $user_id) = @_;

    my $sql = 'SELECT note_id, title, body, creator_id, time FROM crnote '.
              'JOIN notes '.
              'on '.
              'crnote.note_id == notes.id AND crnote.creator_id = ? ';
    my $notesMine = $self->{'dbh'}->selectall_arrayref($sql, {Slice => {}}, $user_id);

    $sql = 'SELECT note_id, title, body, shared_id, shared_from, time FROM shnotes '.
              'JOIN notes '.
              'on '.
              'shnotes.note_id == notes.id AND shnotes.shared_id = ? ';

    my $notesShared = $self->{'dbh'}->selectall_arrayref($sql, {Slice => {}}, $user_id);

    return {} if !scalar(@{$notesMine}) && !scalar(@{$notesShared});

    my $flds = $notesMine->[0];
    foreach my $key (keys %{$flds}) {
        foreach my $note (@{$notesMine}) {
            $note->{$key} = decode('utf8', $note->{$key});
        }
    }

    $flds = $notesShared->[0];
    foreach my $key (keys %{$flds}) {
        foreach my $note (@{$notesShared}) {
            $note->{$key} = decode('utf8', $note->{$key});
        }
    }

    my $sth = $self->{'dbh'}->prepare('SELECT shared_id FROM shnotes WHERE note_id = ? ;');

    foreach (@{$notesMine}) {
        $_->{'body'} = [split '\r\n', $_->{'body'}];
        my $note_id = $_->{'note_id'};
        $sth->execute($note_id);
        my @shrd = (map{@{$_}} @{$sth->fetchall_arrayref()});
        my @sharedWith = (map {$self->GET_user($_)} @shrd); 
        $_->{'sharedWith'} = \@sharedWith;
        $_->{'creator_id'} = $self->GET_user($_->{'creator_id'});
        $_->{'note_id'} =  unpack 'H*', pack 'L', $_->{'note_id'};
    }

    foreach (@{$notesShared}) {
        $_->{'body'} = [split '\r\n', $_->{'body'}];
        my $note_id = $_->{'note_id'};
        $_->{'shared_ids'} = $self->GET_user($_->{'shared_from'});
        $_->{'note_id'} =  unpack 'H*', pack 'L', $_->{'note_id'};
    }

    push @{$notesMine}, @{$notesShared};
    return $notesMine;
}

sub GET_note {
    my ($self, $note_id) = @_;
    my $note = $self->{'dbh'}->selectrow_hashref('SELECT title, body FROM notes WHERE id = ?', {}, $note_id);

    foreach my $key (keys %{$note}) {
        $note->{$key} = decode('utf8', $note->{$key});
    }
    return $note;
}

sub CHECK_id {
    my ($self, $id) = @_;
    my $sth = $self->{'dbh'}->selectrow_arrayref(
        'SELECT COUNT(*) FROM notes WHERE id = (?)',
        {}, 
        $id,
    );
    return $sth->[0];
}

sub CHECK_userid {
    my ($self, $id) = @_;
    my $sth = $self->{'dbh'}->selectrow_arrayref(
        "SELECT COUNT(*) FROM auth WHERE id = ?",
        {},
        $id,
    );
    return $sth->[0];
}

sub GET_id {
    my ($self, $user) = @_;
    my $chk = $self->{'dbh'}->selectrow_arrayref(
        "SELECT id FROM auth WHERE user = ?",
        {Slice => {}},
        $user,
    );
    return $chk ? $chk->[0] : undef;
}

sub GET_user {
    my ($self, $id) = @_;
    
    my $chk = $self->{'dbh'}->selectrow_arrayref(
        "SELECT user FROM auth WHERE id = ?",
        {Slice => {}},
        $id,
    );
    return $chk ? $chk->[0] : undef;
}

1;
