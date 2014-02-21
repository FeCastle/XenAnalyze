#!/bin/bash
#########################################################################
## passData.sh
##
## This script is used to pass data between the Xen Domains
## Domain-0 is used to collect and pars the data
##
## The xen tools need to be present in DomU for this to work
##  See HowTo.txt or http://silviud.blogspot.com/2011/09/from-domu-read-xenstore-ec2-linode-etc.html
##
## Author:  Deron Jensen
## Date:    01/16/2014
## Email:   deron@cs.pdx.edu, fecastle@gmail.com
##
#########################################################################
. ./common.sh

#########################################################################
# signalGuests
#   This function is only run in Dom0. Set /data/analysis/run "on" in the 
#   guest domains.
#########################################################################
function signalGuests {
	for guestDomID in `${XENSTORE_LIST} /local/domain`; do
		if [ $guestDomID != "0" ]; then 
			echo "Setting ${1} in $guestDomID to $2"
			$XENSTORE_WRITE /local/domain/${guestDomID}/${1} $2 
		fi
	done
}

#########################################################################
# waitForGuests
#   This function is only run in Dom0.  Wait for guest machines to 
#   complete a task.
#########################################################################
function waitForGuests {
	while [ 1 == 1 ]; do
		COUNTER=0
	  	#for guestDomID in `${XENSTORE_LIST} /local/domain`; do
	  	for guestDomID in 25 26 27 28; do
			# if [ $guestDomID != "0" ]; then 
			# For test only wait for 26 VM2 #
			runTest=$($XENSTORE_READ /local/domain/${guestDomID}/${1} )
			echo "$1 in guest $guestDomID is $runTest"
			if [ ${runTest}x == ${2}x ]; then
				COUNTER=$[$COUNTER +1]
			fi 
			echo "There are ${COUNTER} guests that are ${2}"
			if [ $COUNTER == "4" ]; then
				echo "All Guests Complete!"
				sleep 1;
				return;
			fi
			
	  	done
	  	sleep 1
	done
}

#########################################################################
# doDomHost
# 
# pass in the name of the benchmark to run.
#########################################################################
function doDomHost {
	echo "I am Domain Host - Monitor stats."
	./collectHost.pl &
	signalGuests ${dataCollect} on
	sleep 2
	# signalGuests ${benchmark} on
	signalGuests ${benchmark} $1
	waitForGuests ${benchmark} off
	signalGuests ${dataCollect} off
	sleep 2
	killall -q -1 collectHost.pl
}

#########################################################################
# doDomGuest
#########################################################################
function doDomGuest {
	echo "I am a Guest Domain."
	collectData="off"
	startBench="off"
	while [ 1 == 1 ]; do
		# for sub in `${XENSTORE_LIST} data`; do
		#	echo -n "$sub -> "
		#	$XENSTORE_READ data/$sub
		# done

		analysis=$($XENSTORE_READ ${dataCollect} 2>/dev/null)
		if [[ $analysis == "on" ]]; then
			if [[ $collectData == "off" ]]; then
				echo "Starting Analysis"
				collectData="on"
				./collectGuest.pl &
			fi
		elif [[ $analysis == "off" ]]; then
			echo "Analysis is Off"
			killall -q -1 collectGuest.pl
		fi

		doBench=$($XENSTORE_READ ${benchmark} 2>/dev/null)
		if [[ $doBench != "off" ]]; then
			if [[ $startBench == "off" ]]; then
				echo "Starting Benchmark"
				startBench="on"
				$doBench
				### Signal the Host (Dom-0) we are done ###
				$XENSTORE_WRITE ${benchmark} off
			fi
		fi
		
		sleep 1
	done
}

function cleanup {
	signalGuests ${benchmark} off
	signalGuests ${dataCollect} off
	killall -q -1 collectHost.pl
	for guestDomID in `${XENSTORE_LIST} /local/domain`; do
		xenstore-rm "/local/domain/${guestDomID}/data/analysis/vmstat"
		xenstore-rm "/local/domain/${guestDomID}/data/analysis/diskstat"
	done
}

######################### MAIN ##########################################
if [ $1x == "clean"x ]; then 
	echo "Doing Cleanup...";
	cleanup
	exit 0
fi

if [ ${myUUID}x == "x" ]; then
	echo "Error:  xenstore: Unable to get UID"
fi
echo "${myName} ${myUUID} ${targetMem} ${domid}"

## On the host we can specify what benchmark for the guests to run ##
if [ ${domid} == 0 ]; then
	if [ -n $1 ]; then
		benchCmd=$1
	fi
	doDomHost ${benchCmd}
else
	doDomGuest
fi

