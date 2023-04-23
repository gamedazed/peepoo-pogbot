#! /usr/bin/perl

my $user = qx{wslvar USERNAME};
$user = q{*} unless $user;
chomp $user;
my $cookie_source = qx{ls /mnt/c/Users/$user/AppData/Roaming/Mozilla/Firefox/Profiles/*/cookies.sqlite};
chomp $cookie_source;
print qq{$cookie_source > }, qx{/mnt/c/temp/cookies.sqlite.src};
print qx{cp -v $cookie_source /mnt/c/temp/cookies.sqlite.src};
my $separator  = qq{\t};

my $cmd = qq{sqlite3 -separator '$separator' /mnt/c/temp/cookies.sqlite.src <<- EOF > ./cookies.sqlite
.mode tabs
.header off
select host,
case substr(host,1,1)='.' when 0 then 'FALSE' else 'TRUE' end,
path,
case isSecure when 0 then 'FALSE' else 'TRUE' end,
expiry,
name,
value
from moz_cookies;
EOF};


system($cmd);
my @extract= qx{cat ./cookies.sqlite};
open (my $netscape, '>', './cookies.sqlite');
print $netscape "# Netscape HTTP Cookie File\n";
print foreach (@extract);
print $netscape $_ foreach (@extract);
