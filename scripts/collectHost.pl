#!/usr/bin/perl

sub doResults() {
	print ("Finishing Collect Host Data.\n");
}

############################## MAIN #################################
use Collect qw(findDisk doPre doPost getDelta);
$SIG{'HUP'} = 'doResults';
doPre();
doPost();
%results = getDelta("DISK");
foreach $statkey (keys %results) {
	print ("$statkey -> $results{$statkey}\n");
}
print "VMstat is $Collect::vmstat\n";
