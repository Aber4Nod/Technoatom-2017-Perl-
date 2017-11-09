package Local::Source::FileHandle {
  use base 'Local::Source';
  sub new {
    my ($class, %args) = @_;
    my $selfS = $class->SUPER::new(%args);
    $selfS->{fh} = $args{fh};
    return $selfS;
  }
  sub next {
    my $selfS = shift;
    my $descr = $selfS->{fh};
    while(<$descr>) {
      return $_;
    }
    return undef;
  }
}

1;
