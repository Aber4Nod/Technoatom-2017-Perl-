package Local::Date;

use POSIX qw/strftime mktime/;
use Time::Local;
use Mouse;
use 5.016;
use DDP;
use Local::Date::Interval;

has day => (
    is => 'rw', isa => 'Int',
    trigger => sub {
        my ($self, $nv, $ov) = @_;
        if (defined $ov) {
            $self->epoch($self->localCalc()) if $self->day != $ov;
        }
    }
);

has month => (
    is => 'rw', isa => 'Int',
    trigger => sub {
        my ($self, $nv, $ov) = @_;
        if (defined $ov) {
            $self->epoch($self->localCalc()) if $self->month != $ov;
        }
    }
);

has year => (
    is => 'rw', isa => 'Int',
    trigger => sub {
        my ($self, $nv, $ov) = @_;
        if (defined $ov) {
            $self->epoch($self->localCalc()) if $self->year != $ov;
        }
    }
);
has hours => (
    is => 'rw', isa => 'Int',
    trigger => sub {
        my ($self, $nv, $ov) = @_;
        if (defined $ov) {
            $self->epoch($self->localCalc()) if $self->hours != $ov;
        }
    }
);
has minutes => (
    is => 'rw', isa => 'Int',
    trigger => sub {
        my ($self, $nv, $ov) = @_;
        if (defined $ov) {
            $self->epoch($self->localCalc()) if $self->minutes != $ov;
        }
    }
);
has seconds => (
    is => 'rw', isa => 'Int',
    trigger => sub {
        my ($self, $nv, $ov) = @_;
        if (defined $ov) {
            $self->epoch($self->localCalc()) if $self->seconds != $ov;
        } 
    }
);

has epoch => (
    is => 'rw', isa => 'Int',
    trigger => \&reCalc);
has format => (
    is => 'rw', isa => 'Str',
    trigger => \&checkFormat);

use overload
    '""' => 'to_string',
    '0+' => 'localCalc',
    '+' => 'add',
    '-' => 'minus',
    '-=' => 'subeq',
    '+=' => 'addeq',
    fallback => 1;
    # '<=>' => 'comp';

around 'BUILDARGS', sub {
    my ($orig, $class, %args) = @_;
    if (!$args{epoch}) {
        $args{epoch} = timegm($args{seconds},$args{minutes},$args{hours},
                              $args{day},$args{month}-1,$args{year}-1900);
    }
    return $class->$orig(%args);
};

sub reCalc {
    my $self = shift;
    # say "in rebuilding $self->{epoch}";
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = 
                                                        gmtime $self->epoch;
    $self->day($mday);
    $self->month($mon + 1);
    $self->year($year + 1900);
    $self->hours($hour);
    $self->minutes($min);
    $self->seconds($sec);
}

sub checkFormat {
    # say "checking";
    my $self = shift;
    my @ch = split / /, $self->format;
    my $epoch = $self->epoch ? $self->epoch : time;
    foreach my $cur (@ch) {
        if(strftime($cur, gmtime $epoch) eq $cur || length $cur != 2){
            delete $self->{format};
            return;
        }
    }
}

sub to_string {
    my ($self) = @_;
    if ($self->format){
        return strftime($self->format, gmtime $self->epoch);
    } else {
        return gmtime $self->epoch;
    }
}


sub localCalc {
    my $self = shift;
    return $self->epoch;
}

sub add {
    my ($self, $other) = @_;
    my $otherType = ref($other);
    if ($otherType && $otherType ne "Local::Date::Interval") {
        die "undef";
    }
    if ($otherType){
        return Local::Date->new(epoch => $self->epoch+$other->duration);
    } else {
        return $self->epoch + $other;
    }
}

sub minus {
    my ($self, $other, $swap) = @_;
    my $otherType = ref($other);
    if ($swap || $otherType && $otherType ne "Local::Date::Interval" &&
                                              $otherType ne "Local::Date") {
        die "undef";
    }
    # my $i = $swap ? -1 : 1; 
    if ($otherType eq "Local::Date::Interval") {
        return Local::Date->new(epoch => ($self->epoch-$other->duration));
    } elsif ($otherType eq "Local::Date") {
        return Local::Date::Interval->new(duration=>($self->epoch-$other->epoch));
    } else {
        return ($self->epoch - $other);
    }
}

sub subeq {
    my ($self, $other) = @_;
    my $otherType = ref($other);
    if ($otherType && $otherType ne "Local::Date::Interval") {
        die "undef";
    }
    if ($otherType eq "Local::Date::Interval") {
        $self->epoch($self->epoch-$other->duration);
    } else {
        $self->epoch($self->epoch-$other);
    }
    return $self;
}

sub addeq {
    # say "in addeq";
    my ($self, $other) = @_;
    my $otherType = ref($other);
    if ($otherType && $otherType ne "Local::Date::Interval") {
        die "undef";
    }
    if ($otherType eq "Local::Date::Interval") {
        $self->epoch($self->epoch+$other->duration);
    } else {
        $self->epoch($self->epoch+$other);
    }
    return $self;
}

# my $t = __PACKAGE__->new(
#     epoch => time,
#     # format => "%I %m %a",
# );

# say $t+0;
# $t->seconds($t->seconds+10);
# say $t+0;
# $t->year($t->year+1);
# say $t+0;

# p $t;
# say $t < 7200;
# my $c = $t++;
# say $c;
# say $t;
# my $t1 = __PACKAGE__->new(
#     epoch => time,
#     format => "%I %m %a",
# );
# ++$t;

1;
