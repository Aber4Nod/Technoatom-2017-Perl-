package Local::Reducer::Sum {
  use base 'Local::Reducer';
  sub new {
    my ($class, %args) = @_;
    my $selfR = $class->SUPER::new(%args);
    $selfR->{field} = $args{field};
    return $selfR;
  }

  sub reduce_n ($) {
    my ($selfR, $c) = @_;
    return $selfR->reduce_all($c);
  }

  sub reduce_all {
    my ($selfR, $c) = @_;
    my $e = defined $c ? 1 : 0;
    my $str = $selfR->{source}->next;
    while ($str && ($e ? $c : 1)) {
      my $self = $selfR->{row_class}->new(str => $str);
      if (defined $self) {
        my $value = $self->get($selfR->{field},undef);
        if (defined $value) {
          $selfR->{initial_value} += $value;
        }
      }
      if ($e ? --$c : 1) {
        $str = $selfR->{source}->next;
      }
    }
    return $selfR->reduced;
  }

  sub reduced {
    my $selfR = shift;
    return $selfR->{initial_value};
  }
}

1;
