package Local::Row::JSON {
  use base 'Local::Row';
  sub new {
    my ($class, %args) = @_;
    my $self = $class->SUPER::new(%args);
    $self->{str} = $args{str};
    if (substr($self->{str},0,1) ne "{" || substr($self->{str},-1,1) ne "}") {
      return undef;
    } else {
      my @arr = split //, $self->{str};
      my $ind = $#arr-1;
      $self->{str} = join '', @arr[1..$ind];

      $_ = $self->{str};
      $ind = length $self->{str};
      if ($ind) {
        while (/(?:["]{1}([^:]*?)["]{1}:([^:]*?)(,|$))\K/g) {
          $self->{$1} = $2;
          $ind-=(length($1) + 2 + length($2) + 2);
        }
        $ind++;
        if ($ind) {
          delete $self->{str};
          return undef;
        }
      }
      delete $self->{str};
      return $self;
    }
  }
}

1;
