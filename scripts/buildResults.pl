#!/usr/bin/perl
#########################################################################
## buildResults.pl
##
## This is a small script to parse the vmstat output of getScaleFactor
##
## getScaleFactor will flush the memory to disk before data is collected, so 
## we can calculate the memory used by subtracting the starting Free and Cache
## memory fron the end Free and Cache Memory.
##
## For Swap and IO it is reports in Memory/s and Blocks/s, so we take the average
## after skipping the first line.  The first line is the average since the 
## last reboot.
## 
## Author:  Deron Jensen
## Date:    08/01/2013
## Email:   deron@cs.pdx.edu, fecastle@gmail.com
##
#########################################################################
my $file = $ARGV[0];
my $FREE = 4;
my $CACHE = 6;
my $SWAPIN = 7;
my $SWAPOUT = 8;
my $BYTESIN = 9;
my $BYTESOUT = 10;
my $WAIT = 16;
my $memUsed;
my $cacheUsed;

if (! $file ) {
	print (STDERR "Error:  Filename required.\n");
	exit 1;
}

print "Parsing file $file.\n";
$headerFound = "no";
$tpsFound = "no";
$freeStart = 0;
$cacheStart = 0;
$lines = 0;
$swapIn = 0;
$swapOut = 0;
$bytesIn = 0;
$bytesOut = 0;
$wait = 0;

open (MYFILE, $file) || die "File $file - Unable to read.";
 while (<MYFILE>) {
 	chomp;
	if ($_ =~ /swpd\s*free/) {
		$headerFound = "yes";
	}
	elsif ($headerFound eq "yes") {
		if ($_ =~ /^tps/) {
			$tpsFound = "yes";
			$memUsed = $freeStart - $data[$FREE];
			$cacheUsed = $data[$CACHE] - $cacheStart;
			print "END $data[$FREE] - $data[$CACHE]\n";
		}
		elsif ($tpsFound eq "no" && $tpsFound eq "no") {
			@data = split(/\s+/);
			if ($freeStart == 0) {
				print "START $data[$FREE] - $data[$CACHE]\n";
				$freeStart = $data[$FREE];
				$cacheStart = $data[$CACHE];
			}
			## Get the average excluding first line ##
			else {
				++$lines;
				$swapIn += $data[$SWAPIN];
				$swapOut += $data[$SWAPOUT];
				$bytesIn += $data[$BYTESIN];
				$bytesOut += $data[$BYTESOUT];
				$wait += $data[$WAIT];
			}
		}
	}
 }
 close (MYFILE); 

print "There are $lines lines\n";
$swapIn = $swapIn/$lines;
$swapOut = $swapOut/$lines;
$bytesIn = $bytesIn/$lines;
$bytesOut = $bytesOut/$lines;
$wait = $wait/$lines;

print "Memory,Cache,SwapIn,SwapOut,BytesIn,BytesOut,IOWait\n";
printf "%d,%d,%d,%d,%d,%d,%d\n", $memUsed, $cacheUsed, $swapIn, $swapOut, $bytesIn, $bytesOut, $wait;

