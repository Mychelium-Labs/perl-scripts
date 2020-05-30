#!/usr/bin/perl

my $file = shift || 'PDF_Chapter_4o.txt';
die if ! -e $file;

local *F;
open F,'<',$file or die $!;
local $/ = "\n";
my @buf = <F>;
printf "file: $file\n";
close F;

printf "buf: %u\n",scalar(@buf);

my $i = 0;
my $skip = 0;
my $string = '';
foreach my $line (@buf) {
  $i++;
  $line =~ y/\r//d; # remove dos CR
  chomp $line;
  if ($line =~ m/^Page \d/) { 
    $skip = 55;
  }
  if ($line =~ m/^60(\d+)/) {
    printf "\n// page : %u\n",$1;
  }
  if ($skip > 0) {
    print "#$i skip:$skip -($line)\n" if $dbug;
    $skip--;
    next;
  } else {
    print ".$i +[$line]\n" if $dbug;
  }
  my ($num,$content);
  if ($line =~ m/^\d+ /) {
     ($num,$content) = split(/ +/,$line,2); 
  } else {
     ($num,$content) = (0,$line);
  }
  if (length($content) < 32) {
  printf "%s\n",$content; # title or subtitle;
  } elsif ($content =~ m/^[A-Z]/) {
  printf "\n%s",$content;
  } elsif ($content) {
  printf "%s",$content;
  } else {
  printf "\n%03u: %s (#%u)\n",$i,$content,$num;
  }
}

exit $?;

1;
