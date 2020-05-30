#!/usr/bin/perl


my $file = shift;
die unless -e $file;
my ($fpath,$bname,$ext) = &bname($file);
my ($atime,$mtime,$size) = (lstat($file))[8,9,7];
$ext = 'eml' if ($bname eq 'original_msg');

die if $size < 10;

my $i = 0;
while (1) {
   $i++;
   $name = sprintf('%s-%02d.%s',$bname,$i,$ext);
   last if (! -e $name);
}
local *F;
open F,'>',$name;
printf F "From - %s\r\n",&mdate($mtime);
local *M; open M,'<',$file; local $/ = undef;
print F <M>; 
close M;
utime($atime,$mtime,$name);

close F;
#rename $file, $name;

exit $?;

# -----------------------------------------------------
sub bname { # extract basename etc...
  my $f = shift;
  $f =~ s,\\,/,g; # *nix style !
  my $s = rindex($f,'/');
  my $fpath = ($s > 0) ? substr($f,0,$s) : '.';
  my $file = substr($f,$s+1);

  if (-d $f) {
    return ($fpath,$file);
  } else {
  my $p = rindex($file,'.');
  my $bname = ($p>0) ? substr($file,0,$p) : $file;
  my $ext = lc substr($file,$p+1);
     $ext =~ s/\~$//;
  
  $bname =~ s/\s+\(\d+\)$//;
  $bname =~ s/-\d+$//;

  return ($fpath,$bname,$ext);

  }

}
# -----------------------------------------------------
sub mdate { # return HTTP date (RFC-1123, RFC-2822) 
  my $DoW = [qw( Sun Mon Tue Wed Thu Fri Sat )];
  my $MoY = [qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec )];
  my ($sec,$min,$hour,$mday,$mon,$yy,$wday) = (gmtime($_[0]))[0..6];
  my ($yr4,$yr2) =($yy+1900,$yy%100);
  # From - Thu Jul 26 19:25     2018

  my $date = sprintf "From %s %3s %3s %2d %02d:%02d %3s %4d",
         '-', $DoW->[$wday],$MoY->[$mon],$mday,$hour,$min,$ENV{'TZ'},$yr4;
  return $date;
}
# -----------------------------------------------------

1;
