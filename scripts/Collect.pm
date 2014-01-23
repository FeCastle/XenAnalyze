##############################################################################
# Collect.pm
#  
#  common functions for host and guest to collect data from /proc/vmstats
#  and /proc/diskstats.  For now we only use /sys/block/<name>/vmstat
#  to collect specific disk stats.
# 
#  https://www.kernel.org/doc/Documentation/iostats.txt
#
#  May need to mount 'sysfs' - Example: /etc/fstab line
#	none /sys sysfs defaults 0 0
#  
##############################################################################
package Collect;
use Exporter qw(import);
our @EXPORT_OK = qw(findDisk doPre doPost getDelta);

$vmstat = "/proc/vmstat";
$diskstat = findDisk();
our $xenVmstat = "data/analysis/vmstat";
our $xenDiskstat = "data/analysis/diskstat";

my %vmPre, %vmPost;
my %diskPre, %diskPost;
my @diskKeys;    # /proc/diskstats do not have "names"
$diskKeys[0] = "r_total";
$diskKeys[1] = "r_merged";
$diskKeys[2] = "r_sectors";
$diskKeys[3] = "r_ms";
$diskKeys[4] = "w_total";
$diskKeys[5] = "w_merged";
$diskKeys[6] = "w_sectors";
$diskKeys[7] = "w_ms";
$diskKeys[8] = "IO_cur";
$diskKeys[9] = "IO_ms";
$diskKeys[10]= "IO_weighted";

 
##############################################################################
# findDisk
#   The disk may be a full SCSI disk (sda) or a volume group (dm-0)
##############################################################################
sub findDisk() {
	@disks = ("dm-0", "sda");
	foreach $disk (@disks) {
		$file = "/sys/block/$disk/stat";
		if ( -e $file ) {
			return $file;
		}
	}
	
	die "findDisk:  Unable to get disk I/O stats";
}

sub doPre() {
	print ("Collect Preprocessing Data.\n");
	collectVM(0);
	collectDisk(0);
}

sub doPost() {
	print ("Collect Postprocessing Data.\n");
	collectVM(1);
	collectDisk(1);
}

sub collectVM() {
	$x = shift;
	open (VMSTAT, "<", $vmstat) || die "Unable to read $!";
	while (<VMSTAT>) {
		@data = split (/\s+/);
		if ($x eq 0) {
			$vmPre{$data[0]} = $data[1];
		}
		else {
			$vmPost{$data[0]} = $data[1];
		}
	}
	close (VMSTAT);
}

###########################################################################
#
# See Dom-0 /sys/bus/xen-backend/devices/vbd-26-51712/statistics/rd_req
# See Dom-0 /sys/bus/xen-backend/devices/vbd-<ID>-51712/statistics/rd_req
###########################################################################
sub collectDisk() {
	$x = shift;
	open (DISKSTAT, "<", $diskstat) || die "Unable to open $!";
	while (<DISKSTAT>) {
		$_ =~ s/^\s+//;    ## 
		@data = split (/\s+/);
		(scalar @diskKeys == scalar @data) || die "$diskstat - Mismatch";
		for ($i=0; $i< scalar @diskKeys; ++$i) {
			if ($x eq 0) {
				print "PRE Collecting Disk:  $diskKeys[$i] -> $data[$i]\n";
				$diskPre{$diskKeys[$i]} = $data[$i];
			}
			else {
				print "POST Collecting Disk:  $diskKeys[$i] -> $data[$i]\n";
				$diskPost{$diskKeys[$i]} = $data[$i];
			}
		}
	}
	close (DISKSTAT);
}

sub getDelta {
	$val = shift;
	%ret;
	print ("Getting delta for $val\n");
	if ($val =~ /VM/) {
		foreach $statkey  (keys %vmPre) {
			$delta = $vmPost{$statkey} - $vmPre{$statkey};
			$delta =~ s/-/_/;    ## Replace negative numbers with _ for CLI
			$ret{$statkey} = $delta;
			# $cmd = "xenstore-write $xenVmstat/$statkey $delta";
			# print "$cmd\n";
			# `$cmd`;
		}
	}
	elsif ($val =~ /DISK/) {
		foreach $statkey  (keys %diskPre) {
			$delta = $diskPost{$statkey} - $diskPre{$statkey};
			$delta =~ s/-/_/;    ## Replace negative numbers with _ for CLI
			if ($statkey =~ /IO_cur/) {
				$delta = $diskPost{$statkey};
			}	
			$ret{$statkey} = $delta;
			# $cmd = "xenstore-write $xenDiskstat/$statkey $delta";
			# print "$cmd\n";
			# `$cmd`;
		}
	}
	else {
		die "Unknown argument in Collect::getDelta.\n";
	}
	
	return %ret
}

1;
