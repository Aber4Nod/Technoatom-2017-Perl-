use echo;
use pwd;
use kill;
use ps;
use cd;

my %h = (
  echo => \&echo::_echo,
  pwd => \&pwd::_pwd,
  kill => \&kill::_kill,
  ps => \&ps::_ps,
  cd => \&cd::_cd,
);

while (<STDIN>) {
  my $cmd = $_ || die "Input smth";
  my @inpPr = split /\|/ , $cmd;
  unless ($#inpPr) {
    $inpPr[$comp] =~ s{(^\s*)(?=\S+)}{};
    my @inp = split / /, $inpPr[$comp];
    my $key = $inp[0];
    $cmd = join ' ', @inp[1..$#inp];
    $key =~ s/\n//;
    my $forw;
    if ($h{$key}) {
      $resultP = $h{$key}->($cmd);
      print @{$resultP};
      next;
    } elsif (-e "/bin/$key" and -x "/bin/$key") {
      $forw = "/bin";
    } elsif (-e "$ENV{PWD}/$key" and -x "$ENV{PWD}/$key") {
        $forw = "$dir";
    } else {
      my @arrPath = split /:/, $ENV{PATH};
      for my $dir (@arrPath) {
        if (-e "$dir/$key" and -x "$dir/$key") {
          $forw = "$dir";
          last;
        }
      }
    }
    unless (defined $forw) {
      print "-bash: $key: command not found \n";
    }
    exec "$forw/$key $cmd";
  } else {
    my $pid = open(KID_TO_READ, '-|');
    return(-1, "Can't fork: $!") unless defined $pid;
    if ($pid) {
      while (<KID_TO_READ>) {
        print $_;
      }
      waitpid($pid, 0);
      close(KID_TO_READ);
    } else {
      open(STDERR, '>&STDOUT');
      my @inpPr = split /\|/ , $cmd;
      my ($descr, $descrPrev);
      my $resultP = [];
      for my $comp (0..$#inpPr) {
        $inpPr[$comp] =~ s{(^\s*)(?=\S+)}{};
        my @inp = split / /, $inpPr[$comp];
        my $key = $inp[0];
        $cmd = join ' ', @inp[1..$#inp];
        $key =~ s/\n//;
        my $forw;
        if ($h{$key}) {
          if ($key cmp "cd") {
            $resultP = $h{$key}->($cmd);
          } else {
            $resultP = '';
          }
          next;
        } elsif (-e "/bin/$key" and -x "/bin/$key") {
          $forw = "/bin";
        } elsif (-e "$ENV{PWD}/$key" and -x "$ENV{PWD}/$key") {
            $forw = "$dir";
        } else {
          my @arrPath = split /:/, $ENV{PATH};
          for my $dir (@arrPath) {
            if (-e "$dir/$key" and -x "$dir/$key") {
              $forw = "$dir";
              last;
            }
          }
        }
        unless (defined $forw) {
          print "-bash: $key: command not found \n";
        }
        pipe(PAR, KID);
        pipe(IN, OUT);
        if (my $pidP = fork()) {
          if ($comp) {
            close (PAR);
            print KID @{$resultP};
            close (KID);
            close (OUT);
            $resultP = [];
            while (<IN>) {
              push @{$resultP}, $_;
            }
            close (IN);
            waitpid ($pidP, 0);
          } else {
            close (KID);
            while (<PAR>) {
              push @{$resultP}, $_;
            }
            close (PAR);
            waitpid ($pidP, 0);
          }
        } else {
          if ($comp) {
            open (STDIN, "<&PAR");
            close (KID);
            close (PAR);
            close (IN);
            open (STDOUT,">&OUT") or die $!;
            close (OUT);
            exec "$forw/$key $cmd";
            # exit;
          } else {
            close (PAR);
            open (STDOUT,">&KID") or die $!;
            close (KID);
            exec "$forw/$key $cmd";
            # exit;
          }
        }
      }
      print @{$resultP};
      exit 0;
    }
  }
}
