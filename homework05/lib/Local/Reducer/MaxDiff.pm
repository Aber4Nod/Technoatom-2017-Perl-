package Local::Reducer::MaxDiff {
  use base 'Local::Reducer';
  sub new {
    my ($class, %args) = @_;
    my $selfR = $class->SUPER::new(%args);
    $selfR->{top} = $args{top};
    $selfR->{bottom} = $args{bottom};
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
        my $KVal = $self->get($selfR->{top},undef);
        my $VVal = $self->get($selfR->{bottom},undef);
        if (defined $KVal && defined $KVal) {
          if ($KVal - $VVal > $selfR->{initial_value} || !(defined $selfR->{initial_value})) {
            $selfR->{initial_value} = $KVal - $VVal;
          }
          if ($VVal - $KVal > $selfR->{initial_value}) {
            $selfR->{initial_value} = $VVal - $KVal;
          }
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
