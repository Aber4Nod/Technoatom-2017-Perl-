package echo;

sub _echo {
  local $_ = shift;
  my $retArr = [];
  while (/(\$)?([^\$]*)/g) {
    unless(defined $1) {
      push @{$retArr}, $2;
      next;
    }
    my @a = split(//, $2);
    pop @a;
    my $ret = join '', @a;
    if (defined $ENV{$ret} && $a[-1]!="\n") {
      return;
    } elsif (defined $ENV{$ret}) {
      push @{$retArr}, $ENV{$ret}, "\n";
    } elsif ($a[0] =~ m/[1-9]/) {
      @a = @a[1..$#a];
      push @{$retArr}, join('', @a), "\n";
    } elsif ($a[0] =~ m/0/) {
      @a = @a[1..$#a];
      push @{$retArr}, "-bash", join('', @a), "\n";
    }
  }
  return $retArr;
}

1;
