  #!/usr/bin/env perl
  
  use warnings;
  use Cwd;
  
  my $strUsage = sprintf("Usage: %s a b c ...\n",Cwd::abs_path($0));
  
  if (@ARGV == 0) {
    die sprintf("Bad arguments ...\n
	\r%s",$strUsage);
  } elsif (@ARGV != 3) {
    die sprintf("Not a quadratic equation ...\n
		\r%s",$strUsage);
  } else {
    die "a b c must be integers ...\n"  if $ARGV[0] !~ m/^-?\d+$/
					or $ARGV[1] !~ m/^-?\d+$/
					or $ARGV[2] !~ m/^-?\d+$/;
    die "a must be non zero ...\n" if $ARGV[0] == 0;
  }
  
  my ($a, $b, $c) = @ARGV;
  my ($x1, $x2);
  
  my $D = $b**2 - 4*$a*$c;
  
  die "The equation hasn't real roots ...\n" if $D < 0;
  
  ($x1, $x2) = ((-$b+sqrt($D))/2/$a, (-$b-sqrt($D))/2/$a);

  print $x1 . ", " . $x2;
  