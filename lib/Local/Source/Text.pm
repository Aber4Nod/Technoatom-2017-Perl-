package Local::Source::Text {
  use base 'Local::Source';
  sub new {
    my ($class, %args) = @_;
    my $selfS = $class->SUPER::new(%args);
    $selfS->{text} = $args{text};
    $selfS->{delimiter} = defined $args{delimiter} ? $args{delimiter} : "\n";

    return $selfS;
  }
  sub next {
    my $selfS = $_[0];
    if ($selfS->{text}) {
        $selfS->{text} =~ /((.*?)(?:$selfS->{delimiter}|$)\K)/;
        my $retB = $2;
        $selfS->{text} =~ s/$1//;
        return $retB;
    } else {
      return undef;
    }
  }
}

1;
