package pwd;

use Cwd;

sub _pwd {
  my $retArr = [];
  # push @{$retArr}, $ENV{PWD}, "\n";
  push @{$retArr}, cwd(), "\n";
  return $retArr;
}

1;
