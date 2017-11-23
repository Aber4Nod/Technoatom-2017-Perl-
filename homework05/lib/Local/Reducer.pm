package Local::Reducer {
  sub new {
    my ($class, %args) = @_;
    my $selfR = {};
    bless $selfR, $class;
    $selfR->{source} = $args{source};
    $selfR->{row_class} = $args{row_class};
    $selfR->{initial_value} = $args{initial_value};
    return $selfR;
  }
}

1;
