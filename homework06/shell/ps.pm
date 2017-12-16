package ps;

use Time::localtime;
use POSIX qw(ceil sysconf _SC_CLK_TCK);
use Cwd 'abs_path';

sub _ps {
  opendir (my $dh, '/proc') or die $!;
  my $retArr = [];
  push @{$retArr}, sprintf("%6s", "PID"), sprintf("%8s", "PPID"), sprintf("%8s", "PGID"),
  "  TTY", sprintf("%14s", "UID"), sprintf("%9s", "STIME"), " CMD\n";

  while (my $fname = readdir $dh) {
    if ($fname =~ m/^\d+$/) {
        my (@ret, @retf, @fin, $st);
          @ret = _start_time($fname);
          my $rv = _get_tty($fname);
          if ($rv && $rv cmp 'null') {
            push @retf, "  " . $rv;
            opendir (my $dhi, "/proc/$fname") or die $!;
            while (my $fnamein = readdir $dhi) {
              unless ($fnamein cmp "loginuid" && $fnamein cmp "comm") {
                open(READ_IN, '<', "/proc/$fname/$fnamein") or die $!;
                my $r = <READ_IN>;
                $r =~ s/\n//;
                push @retf, $r;
                close(READ_IN);
              }
            }
            push @fin, @ret[0..2], $retf[0],
                              sprintf("%12d",$retf[2]), @ret[3], ' ', @retf[1];
            push @{$retArr}, @fin[0..$#fin], "\n";
            closedir($dhi);
          }
    }
  }
  closedir($dh);
  return $retArr;
}

sub _start_time {
  my $pid = shift;
  my $tickspersec = sysconf(_SC_CLK_TCK);
  open(my $f,'<',"/proc/uptime");
  my ($secs_since_boot) = split /\./, <$f>;
  $secs_since_boot *= $tickspersec;
  close($f);
  open(my $f,'<',"/proc/$pid/stat");
  my @start_time = (split / /, <$f>);
  close($f);
  my @ret = (split / /, ctime(ceil(time() -
                      (($secs_since_boot - $start_time[21]) / $tickspersec))));
  return (sprintf("%6d", $start_time[0]), sprintf("%8d", $start_time[3]),
          sprintf("%8d", $start_time[4]), sprintf("%9s", $ret[4]));
}
sub _get_tty {
  my $pid = shift;
  my $r = abs_path("/proc/$pid/fd/0");
  $r =~ s/\n//;
  my @a = split '/', $r;
  @a = @a[2..$#a];
  close (READ_IN);
  return scalar @a ? join '/', @a : 0;
}

1;
