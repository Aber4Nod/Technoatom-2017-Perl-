package Local::Reducer::MinMaxAvg {
  use base 'Local::Reducer';
  sub new {
    my ($class, %args) = @_;
    my $selfR = $class->SUPER::new(%args);
    $selfR->{field} = $args{field};
    $selfR->{max} = undef;
    $selfR->{min} = undef;
    $selfR->{lineNum} = 0;
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
          $selfR->{max} = defined $selfR->{max} ? ($selfR->{max} < $value ?
                                              $value : $selfR->{max}) : $value;
          $selfR->{min} = defined $selfR->{min} ? ($selfR->{min} > $value ?
                                              $value : $selfR->{min}) : $value;
          $selfR->{lineNum}++;
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
    return Local::Reducer::MinMaxAvg::MinMaxAvgReturn->new(max => $selfR->{max},
    min => $selfR->{min},
    avg => $selfR->{initial_value}/$selfR->{lineNum},
    );
  }

}
package Local::Reducer::MinMaxAvg::MinMaxAvgReturn {
  sub new {
    my ($class, %args) = @_;
    my $self = {};
    bless $self, $class;
    $self->{max} = $args{max}+0;
    $self->{min} = $args{min}+0;
    $self->{avg} = $args{avg}+0;
    return $self;
  }
  sub get_max {
    my $selfT = shift;
    $selfT->{max};
    return $selfT->{max};
  }
  sub get_min {
    my $selfT = shift;
    return $selfT->{min};
  }
  sub get_avg {
    my $selfT = shift;
    return $selfT->{avg};
  }
}

1;
