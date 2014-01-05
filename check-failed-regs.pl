#!/usr/bin/perl -w
use strict;
use warnings;
my (@failhost);
my %currblocked;
my %addblocked;
my $action;
 
my $iptable_path = "/sbin/iptables";
my @whitelist = ("175.16.221.35");


open (MYINPUTFILE, "/var/log/asterisk/full") or die "\n", $!, "Does log file file exist\?\n\n";
 
while (<MYINPUTFILE>) {
    my ($line) = $_;
    chomp($line);
    if ($line =~ m/\' failed for \'(.*?)\' - No matching peer found/) {
        push(@failhost,$1);
    }
    if ($line =~ m/\' failed for \'(.*?)\' - Peer is not supposed to register/) {
        push(@failhost,$1);
    }
    if ($line =~ m/\' failed for \'(.*?)\' - Wrong password/) {
        push(@failhost,$1);
    }
    if ($line =~ m/ss-noservice/ && $line =~ m/SIP\/(.*?)-/) {
        push(@failhost,$1);
    }
    if ($line =~ m/rejected/ && $line =~ m/\((.*?):5060/) {
        push(@failhost,$1);
    }
}
 
my $blockedhosts = `$iptable_path -n -L asterisk`;
 
while ($blockedhosts =~ /(.*)/g) {
    my ($line2) = $1;
    chomp($line2);
    if ($line2 =~ m/(\d+\.\d+\.\d+\.\d+)(\s+)/) {
        $currblocked{ $1 } = 'blocked';
    }
}
 
while (my ($key, $value) = each(%currblocked)){
    print $key . "\n";
}
 
if (@failhost) {
    &count_unique(@failhost);
    while (my ($ip, $count) = each(%addblocked)) {
        if (exists $currblocked{ $ip }) {
            print "$ip already blocked\n";
        } else {
		if ($count > 100) {
			my $is_there = grep /$ip/, @whitelist;
        		if ($is_there) {
            			print "good ip address.\n";
			} else {
            			$action = `$iptable_path -I asterisk -s $ip -j DROP`;
            			print "$ip blocked. $count attempts.\n";
            			$action = `/bin/cat /dev/null > /var/log/asterisk/full`;
            			print "asterisk full cleared.\n";
			}
		}
        }
    }
} else {
    print "no failed registrations.\n";
}
 
sub count_unique {
    my @array = @_;
    my %count;
    map { $count{$_}++ } @array;
    map {($addblocked{ $_ } = ${count{$_}})} sort keys(%count);
}
