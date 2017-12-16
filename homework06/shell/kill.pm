package kill;

sub _kill {
  my $par = shift;
  $par =~ s/\n//;
  my @a = split / /, $par;
  $par = @a[0];
  if ($par =~ /^\d*$/) {
    kill -15, @a;
  } else {
    kill $par, @a[1..$#a];
  }
  return;
}

1;
