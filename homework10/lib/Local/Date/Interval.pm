package Local::Date::Interval;

use Mouse;
use 5.016;
use DDP;

has days => (
    is => 'rw', isa => 'Int',
    trigger => sub {
        my ($self, $nv, $ov) = @_;
        if (defined $ov) {
            $self->duration($self->localCalc()) if $self->days != $ov;
        }
    }
);
has hours => (
    is => 'rw', isa => 'Int',
    trigger => sub {
        my ($self, $nv, $ov) = @_;
        if (defined $ov) {
            $self->duration($self->localCalc()) if $self->hours != $ov;
        }
    }
);
has minutes => (
    is => 'rw', isa => 'Int',
    trigger => sub {
        my ($self, $nv, $ov) = @_;
        if (defined $ov) {
            $self->duration($self->localCalc()) if $self->minutes != $ov;
        }
    }
);
has seconds => (
    is => 'rw', isa => 'Int',
    trigger => sub {
        my ($self, $nv, $ov) = @_;
        if (defined $ov) {
            $self->duration($self->localCalc()) if $self->seconds != $ov;
        }
    }
);

has duration => (
    is => 'rw', isa => 'Int',
    trigger => \&reCalc);

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
    if (!$args{duration}) {
        $args{duration} = $args{seconds} + 60*($args{minutes} + 
                                             60*($args{hours} + 24*$args{days}));
    }
    return $class->$orig(%args);
};

sub reCalc {
    my $self = shift;
    $self->days(int($self->duration/(86400)));
    $self->hours(int(($self->duration-$self->days*86400)/3600));
    $self->minutes(int(($self->duration - $self->days*86400 - 
                                                      $self->hours*3600)/60));
    $self->seconds($self->duration - $self->days*86400 - 
                                        $self->hours*3600 - $self->minutes*60);
}

sub to_string {
    my $self = shift;
    return $self->days." days, ".$self->hours." hours, ".$self->minutes." minutes, ".
                                                       $self->seconds." seconds";
}


sub localCalc {
    my $self = shift;
    return $self->duration;
}

sub add {
    my ($self, $other) = @_;
    my $otherType = ref($other);
    if ($otherType && $otherType ne "Local::Date::Interval") {
        die "undef";
    }
    if ($otherType) {
        return Local::Date::Interval->new(duration=>$self->duration+$other->duration);
    } else {
        return $self->duration+$other;
    }
}

sub minus {
    my ($self, $other, $swap) = @_;
    my $otherType = ref($other);
    if ($swap || $otherType && $otherType ne "Local::Date::Interval") {
        die "undef";
    }
    # my $i = $swap ? -1 : 1;

    if ($otherType) {
        return Local::Date::Interval->new(duration=>($self->duration-$other->duration));
    } else {
        return $self->duration - $other;
    }
}

sub subeq {
    my ($self, $other) = @_;
    my $otherType = ref($other);
    if ($otherType && $otherType ne "Local::Date::Interval") {
        die "undef";
    }
    if ($otherType eq "Local::Date::Interval") {
        $self->duration($self->duration-$other->duration);
    } else {
        $self->duration($self->duration-$other);
    }
    return $self;
}

sub addeq {
    my ($self, $other) = @_;
    my $otherType = ref($other);
    if ($otherType && $otherType ne "Local::Date::Interval") {
        die "undef";
    }
    if ($otherType eq "Local::Date::Interval") {
        $self->duration($self->duration+$other->duration);
    } else {
        $self->duration($self->duration+$other);
    }
    return $self;
}

# my $t = __PACKAGE__->new(
#     duration => 60,
# );
# say
# my $t1 = __PACKAGE__->new(
#     duration => 30,
# );
# say $t+$t1;

1;
