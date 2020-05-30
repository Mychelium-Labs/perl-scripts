sub ipfsadd {
   if (! -e $_[-1]) {
      return { wrap => 'QmQmUNLLsPACCz1vLxQVkXqqLX5R1X345qqfHbsf67hvA3Nn'}; # empty dir !
   }
  my $base;
  my @files = ();
  my @dirs = ();
  my @opts = ();
  while (@_) {
    my $f = shift(@_);
    if (-f $f) {
     push @files, $f;
    } elsif (-d $f) {
     push @dirs, $f;
    } elsif ($f =~ m/^-/) {
       push @opts, $f;
    } 
  }

  if (scalar(@dirs) == 0) { # use wrap mode if no dir
     push @opts, '-w';
  } else {
     push @opts, '-r';
  }

  #my $ver = '411';
  #y $ipfs = sprintf '%s\ExtRepos\IPLD\go-ipfs\ipfs_%s.exe',$ENV{SYNC},$ver;
  #y $ipfs = 'c:\opt\tools\go-ipfs\ipfs.exe';
  my $ipfs = 'ipfs';
  my $mh58 = {};
   my $cmd = sprintf '"%s" add %s %s',$ipfs,join(' ',@opts),
        join(' ',map { sprintf '"%s"',$_ } @files, @dirs);
   print "$cmd\n" if $dbug;
   local *EXEC; open EXEC,"$cmd|"; local $/ = "\n";
   while (<EXEC>) {
     print;
     $mh58->{$2} = $1 if m/added\s+(\w+)\s+(.*)/;
     $mh58->{'wrap'} = $1 if m/added\s+(\w+)/;
     $mh58->{'^'} = $1 if m/^(Qm\S+)/;
     die $_ if m/Error/;
   }
   close EXEC;

   # append mhash registry
   my $base = $dirs[-1] || $files[-1];
   my $version = &version($base);
   open F,'>>',$ipyml; # ~/odrive/Tommy/public_html/etc/ipregistry.yml
   printf F "%s: %s %s\n",$base,$version,$mh58->{wrap};
   close F;

   return $mh58;
}
# -----------------------------------------------------------------------
