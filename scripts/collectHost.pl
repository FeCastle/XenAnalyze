#!/usr/bin/perl
use Collect qw(findDisk doPre doPost getDelta);

$basePath = "/local/domain";
$xenDiskstat = $Collect::xenDiskstat;
$xenVmstat = $Collect::xenVmstat;
$hdrFormat  = "%-8s%2s%9s%9s%9s%9s%9s%9s%9s%9s%9s%9s\n";
$lineFormat = "%-8s%2d%9d%9d%9d%9d%9d%9d%9d%9d%9d%9d\n";

print ("xenDiskstat is $xenDiskstat.\n");
sub doResults() {
	$| = 1;    # Flush print 
	print ("Finishing Collect Host Data.\n");
	doPost();
	%results = getDelta("DISK");
	@statkeys = keys %results;
	@hostDisk = ();
	foreach $x (@statkeys) {
		push (@hostDisk, $results{$x});
	}
	print ("---Host Physical Disk---\n");
	printf $hdrFormat, "Domain", @statkeys;
	printf $hdrFormat, "Dom-0", @hostDisk;

	$results = `xenstore-list $basePath`;
	foreach $domID ( split (/\n/, $results)) {
		# $cmd = "xenstore-read $basePath/$domID/$xenVmstat/$statkey";
		# print "$cmd\n";
		# `$cmd`;
		# print ("---Guest Virtual Disk---\n");
		my @guestDisk=();
		$cmd = "xenstore-list $basePath/$domID/$xenDiskstat";
		$stats = `$cmd 2>/dev/null`;
		if ($? == 0) {
			foreach $statkey (@statkeys) {
				$value = `xenstore-read $basePath/$domID/$xenDiskstat/$statkey`;
				$value =~ s/^\s+|\s+$//g;
				push(@guestDisk, $value);
			}
			printf $hdrFormat, "Dom-$domID", @guestDisk;
		}
	}

	%results = getDelta("VM");
	@statkeys = keys %results;
	@hostVM = ();
	foreach $x (@statkeys) {
		push (@hostVM, $results{$x});
	}
	print ("---Host Physical Disk---\n");
	printf $hdrFormat, "Domain", @statkeys;
	printf $hdrFormat, "Dom-0", @hostDisk;

}

############################## MAIN #################################
$SIG{'HUP'} = 'doResults';
doPre();
sleep;

print "Complete!"
