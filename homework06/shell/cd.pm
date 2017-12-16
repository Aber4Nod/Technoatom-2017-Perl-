package cd;

sub _cd {
  my $par = shift;
  $par =~ s/\n//;
  chdir ($par);
  return;
}

1;
