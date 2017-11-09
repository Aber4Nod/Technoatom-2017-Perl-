package Local::Row {
  sub new {
    my ($class, %args) = @_;
    my $self= {};
    bless $self, $class;
  }
  sub get($$) {
    my $self = $_[0];
    return $self->{$_[1]} ? $self->{$_[1]} : $_[2];
  }
}

1;
