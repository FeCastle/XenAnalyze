#!/usr/bin/perl
##############################################################################
# collectData.pl
#  
#  This script collects data from /proc/vmstats
#  and /proc/diskstats.  For now we only use /sys/block/<name>/vmstat
#  to collect specific disk stats.
# 
#  https://www.kernel.org/doc/Documentation/iostats.txt
#
#  May need to mount 'sysfs' - Example: /etc/fstab line
#	none /sys sysfs defaults 0 0
#  
##############################################################################
use Collect qw(findDisk doPre doPost getDelta);
$xenDiskstat = $Collect::xenDiskstat;
$xenVmstat = $Collect::xenVmstat;

print ("Xen Disk Stat area is: $xenDiskstat\n");
print ("Xen VM Stat area is: $xenVmstat\n");
sub doResults() {
	doPost;
	print ("Sending results to Xen Store\n");
	my %results = getDelta("VM");
	foreach $statkey  (keys %results) {
		$delta = $results{$statkey};
		$cmd = "xenstore-write $xenVmstat/$statkey $delta";
		print "$cmd\n";
		`$cmd`;
	}

	my %results = getDelta("DISK");
	foreach $statkey  (keys %results) {
		$delta = $results{$statkey};
		$cmd = "xenstore-write $xenDiskstat/$statkey $delta";
		print "$cmd\n";
		`$cmd`;
	}
}

############################## MAIN #################################
$SIG{'HUP'} = 'doResults';
doPre;
sleep;
doResults;
print ("Guest Complete.\n");

