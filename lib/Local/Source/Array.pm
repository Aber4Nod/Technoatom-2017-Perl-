package Local::Source::Array {
  use base 'Local::Source';
  my $nElem = 0;
  sub new {
    my ($class, %args) = @_;
    my $selfS = $class->SUPER::new(%args);
    $selfS->{array} = $args{array};
    return $selfS;
  }
  sub next {
    my $selfS = $_[0];
    return $selfS->{array}[$nElem++];
  }
}

1;
