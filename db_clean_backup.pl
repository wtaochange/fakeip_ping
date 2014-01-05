#!/usr/bin/perl


$one_month_ago = time();
$one_month_ago -= (2 * 24 * 60 * 60);
print $one_month_ago."\n";



# backup  in 2 hours
$hour = 2;
sleep int(rand($hour*3600));


open(LS_PIPE,"/bin/ls -l /var/lib/asterisk/backups/day-backup/|");
while (<LS_PIPE>) {
	chomp;
	@psefField = split(' ', $_, 9);
	$file_name = "/var/lib/asterisk/backups/day-backup/".$psefField[8];
	$file_date = (stat $file_name)[9];
	if ($file_date < $one_month_ago) {
		#print $file_name." ||| ".$file_date."\n";
		$command = "/bin/rm -rf $file_name";
	print $command."\n";
		system($command);
	}
}
close(LS_PIPE);

# reboot on Saturday after backup
my ($sec, $min, $hr, $day, $month, $year, $weekday, $dayofyr, $junk_yuk) = localtime(time);

if ($weekday == 0) {
	$command = "/sbin/reboot";
	system($command);
}

