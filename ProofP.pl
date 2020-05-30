#!/usr/bin/perl

my $file = shift || 'ProofOfPayment.pdf';
my $info = '--- '."\n";
   $info .= `pdfinfo $file`;

use YAML::Syck qw(Load Dump);
my $info = &Load($info);
my $tic = &get_tics($info->{CreationDate});

printf "%s.\n",Dump($info);
printf "Date: %s.\n",&hdate($tic);

my $cmd = "pdftotext $file";
system $cmd;

# -----------------------------------------------------
sub get_tics2 { # 08/03/2018 
  my $date = shift;
  my ($hh,$mm,$ss) = (localtime($^T))[2,1,0];
  my ($mo,$dd,$yr4) = split'/',$date;
  use Time::Local qw(timelocal);
  my $tics = timelocal($ss,$mm,$hh,$dd,$mo-1,$yr4);
  return $tics - 1;
}
# -----------------------------------------------------
sub get_tics { # Friday, 01 Mar 2018 20:03 CET
  my $NoM = {'Jan'=>0,'Feb'=>1,'Mar'=>2,'Apr'=>3,'May'=>4,'Jun'=>5,
       'Jul'=>6,'Aug'=>7,'Sep'=>8,'Oct'=>9,'Nov'=>10,'Dec'=>11};
  my ($date) = @_;
  my ($dow,$dm,$mo,$yr,$t,$tz);

  if ($date =~ m/(?:(\w+),\s+)?(\d+)\s+(\w+)\s+(\d+)\s+(\S+)(?:\s+(\S+))?/) {
  # Friday, 01 Mar 2018 20:03 CET
     ($dow,$dm,$mo,$yr,$t,$tz) = ($1,$2,$3,$4,$5,$6);
  } elsif ($date =~ m/(?:(\w+)\s)+(\w+)\s+(\d+)\s+(\S+)\s+(\d+)/ ) {
  # Thu Aug  2 23:18:39 2018
     ($dow,$mo,$dm,$t,$yr) = ($1,$2,$3,$4,$5); $tz = 'CEST';
     print "DBUG: dow:$dow mo:$mo dm:$dm t:$t yr:$yr\n";
  }
  use Time::Local qw(timelocal);
  my ($hour,$min,$sec) = split ':',$t,3;
  $ENV{TZ} = $tz;
  my $tic = timelocal($sec,$min,$hour,$dm,$NoM->{$mo},$yr);
  return $tic;
}
# -----------------------------------------------------
sub hdate { # return HTTP date (RFC-1123, RFC-2822) 
  my $DoW = [qw( Sun Mon Tue Wed Thu Fri Sat )];
  my $MoY = [qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec )];
  my ($sec,$min,$hour,$mday,$mon,$yy,$wday) = (gmtime($_[0]))[0..6];
  my ($yr4,$yr2) =($yy+1900,$yy%100);
  # Mon, 01 Jan 2010 00:00:00 GMT

  my $date = sprintf '%3s, %02d %3s %04u %02u:%02u:%02u GMT',
             $DoW->[$wday],$mday,$MoY->[$mon],$yr4, $hour,$min,$sec;
  return $date;
}
# -----------------------------------------------------
1;
