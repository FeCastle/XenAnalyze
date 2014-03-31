#!/usr/bin/perl
use Collect qw(findDisk doPre doPost getDelta);

$basePath = "/local/domain";
$xenDiskstat = $Collect::xenDiskstat;
$xenVmstat = $Collect::xenVmstat;
$hdrFormat  = "%-8s %2s %10s %10s %10s %10s %10s\n";
$lineFormat = "%-8s %2d %10d %10d %10d %10d %10d\n";

### Reporting:  Which VM data do we report ###
my @vmKeys = ("pgpgin", "pgpgout", "pgfault", );
my @diskKeys = ("r_ms", "r_total", "r_sectors");
my %report;

sub doResults() {
	$| = 1;    # Flush print 
	print ("Finishing Collect Host Data.\n");
	doPost();
	%results = getDelta("VM");
	foreach $vmKey (@vmKeys) {
		print "Adding Host key $vmKey -> $results{$vmKey}\n";
		$report{"0"}{$vmKey} = $results{$vmKey};
	}
	%results = getDelta("DISK");
	foreach $diskKey (@diskKeys) {
		print "Adding Host key $diskKey -> $results{$diskKey}\n";
		$report{"0"}{$diskKey} = $results{$diskKey};
	}

	$results = `xenstore-list $basePath`;
	@domIDs = split (/\n/, $results);
	foreach $domID (@domIDs) {
		my @guestDisk=();
		$cmd = "xenstore-list $basePath/$domID/$xenDiskstat";
		$stats = `$cmd 2>/dev/null`;
		if ($? == 0) {
			foreach $key (@diskKeys) {
				$value = `xenstore-read $basePath/$domID/$xenDiskstat/$key`;
				$value =~ s/^\s+|\s+$//g;
				$report{"$domID"}{$key} = $value;
				$report{"U"}{$key} += $value;
				print "Found Dom-$domID Key $key -> $value\n";
			}
			foreach $key (@vmKeys) {
				$value = `xenstore-read $basePath/$domID/$xenVmstat/$key`;
				$value =~ s/^\s+|\s+$//g;
				$report{"$domID"}{$key} = $value;
				$report{"U"}{$key} += $value;
				print "Found Dom-$domID Key $key -> $value\n";
			}
		}
	}

	print ("--- Report ---\n");
	@allKeys = (@vmKeys, @diskKeys);
	printf $hdrFormat, "Domain", @allKeys;
	foreach $domID (keys %report) {
		@domVals = ();
		foreach $key (@allKeys) {
			push(@domVals, $report{$domID}{$key});
		}
		printf $lineFormat, "Dom-$domID", @domVals;	
	}

	## Overhead ##
	print ("Overhd     ");
	foreach $key (@allKeys) {
		$hostVal  = $report{"0"}{$key};
		$guestVal = $report{"U"}{$key};
		# Orginal method ....
		# $overhead = 100 * ($guestVal - $hostVal) / $guestVal;
		
		# New method 
		$overhead = 100 * ($hostVal - $guestVal) / $guestVal;
		printf ("%2.1f      ", $overhead);
	}
	print ("\n");

	return 0;


}

############################## MAIN #################################
$SIG{'HUP'} = 'doResults';
doPre();
sleep;

print "Complete!"
