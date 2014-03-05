#!/usr/bin/perl
use Collect qw(findDisk doPre doPost getDelta);

$basePath = "/local/domain";
$xenDiskstat = $Collect::xenDiskstat;
$xenVmstat = $Collect::xenVmstat;
$hdrFormat  = "%-8s%2s%9s%9s%9s%9s%9s%9s%9s%9s%9s%9s\n";
$lineFormat = "%-8s%2d%9d%9d%9d%9d%9d%9d%9d%9d%9d%9d\n";

my @vmKeys;    # /proc/vmtats has too much info
$vmKeys[0] = "pgpgin";
$vmKeys[1] = "pgpgout";
$vmKeys[2] = "pgfault";
$vmKeys[3] = "pgactivate";
$vmKeys[4] = "pgdeactivate";
$vmKeys[5] = "pgfree";



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
	@hostVM = ();

	# vmKeys defines which fields to display
	foreach $x (@vmKeys) {
		push (@hostVM, $results{$x});
	}
	print ("---Host Virtual Memory---\n");
	printf $hdrFormat, "Domain", @vmKeys;
	printf $hdrFormat, "Dom-0", @hostVM;

	$results = `xenstore-list $basePath`;
	foreach $domID ( split (/\n/, $results)) {
		my @guestVM=();
		$cmd = "xenstore-list $basePath/$domID/$xenVmstat";
		$stats = `$cmd 2>/dev/null`;
		if ($? == 0) {
			foreach $statkey (@vmKeys) {
				$value = `xenstore-read $basePath/$domID/$xenVmstat/$statkey`;
				$value =~ s/^\s+|\s+$//g;
				push(@guestVM, $value);
			}
			printf $hdrFormat, "Dom-$domID", @guestVM;
		}
	}

}

############################## MAIN #################################
$SIG{'HUP'} = 'doResults';
doPre();
sleep;

print "Complete!"
