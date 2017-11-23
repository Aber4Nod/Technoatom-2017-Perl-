package Local::Row::Simple {
  use base 'Local::Row';
  sub new {
    my ($class, %args) = @_;
    my $self = $class->SUPER::new(%args);
    $self->{str} = $args{str};
    $_ = $self->{str};
    my $symb = length $self->{str};
    if ($symb) {
      while (/(?:([^:]*?):([^:]*?)(,|$))\K/g) {
        $self->{$1} = $2;
        $symb-=(length($1) + length($2) + 2);
      }
      $symb++;
      if ($symb) {
        delete $self->{str};
        return undef;
      }
    }
    delete $self->{str};
    return $self;
  }
}

1;
