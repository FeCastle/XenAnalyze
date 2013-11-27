#!/usr/bin/python
###############################################################################
# analyze.py
#
# Author:  Deron Jensen
# Date: November 4, 2013
#
# This uses python psutil module:
# 	https://pypi.python.org/pypi?:action=display&name=psutil#downloads
#   https://pypi.python.org/packages/source/p/psutil/psutil-1.1.2.tar.gz
# 
# Install the python header files:
#   sudo apt-get install python2.7-dev
# Unpack and install
#   tar -xzf psutil*.gz
#   cd psutil-1.1.2
#   sudo python setup.py install
#
###############################################################################
import os
import datetime
import socket
import sys
import psutil
import time

doDebug = True
#############################################################################
#for key in pinfo:
#	print key, " ==> ", pinfo[key]
# p.dict = p.as_dict(['username', 'get_nice', 'get_memory_info',
#                       'get_memory_percent', 'get_cpu_percent',
#                       'get_cpu_times', 'name', 'status'])
#	rss = pinfo['memory_info'].rss
#	vms = pinfo['memory_info'].vms
#	mem = pinfo['memory_percent']
#	cpuUser = pinfo['cpu_times'].user
#	cpuSys = pinfo['cpu_times'].system
#	print "RSS ", rss
#	print "VMS ", vms
#	print "MEM ", mem
#	print "User: ", cpuUser
#	print "Sys: ", cpuSys
#############################################################################

numTop = 5
prevIOProcs = {}
curIOProcs = {}
def diffIO (old, new): return new - old

def doProcess():
	global curIOProcs, prevIOProcs
	print "---------------- Doing Process -----------------"
	for p in psutil.process_iter():
		pinfo = p.as_dict(ad_value='')
		if (pinfo['io_counters'] != ''): 
			readBytes = pinfo['io_counters'].read_bytes
			writeBytes = pinfo['io_counters'].write_bytes
			if ((readBytes > 0) or (writeBytes > 0)):
				if p.pid not in curIOProcs.keys():
					prevIOProcs[p.pid] = [0, 0]
				else:
					prevIOProcs[p.pid] = curIOProcs[p.pid]
				curIOProcs[p.pid] = [readBytes, writeBytes]
				# print "Current:  ", curIOProcs[p.pid]
				# print "Previous: ", prevIOProcs[p.pid]
				print p.name, ": ", map(diffIO, prevIOProcs[p.pid], curIOProcs[p.pid])

def printDebug(msg):
	if (doDebug == True):
		print msg
	
def doCPU():
	printDebug ("Starting System CPU.")
	cpuTimes = psutil.cpu_times()
	print cpuTimes


def doNet():
	printDebug ("Starting System Network.")
	netIO = psutil.net_io_counters()
	print netIO

def doVirtMem():
	printDebug ("Starting System Virtual Mem.")
	virtMem = psutil.virtual_memory()
	print virtMem

def doSwap():
	printDebug ("Starting System Swap.")
	swapMem = psutil.swap_memory()
	print swapMem

def doDiskIO():
	printDebug ("Starting Disk IO.")
	# Return system disk I/O statistics as a namedtuple:
	global diskIO
	diskIO = psutil.disk_io_counters(perdisk=True)
	print diskIO

def doAllSys():
	# doCPU()
	# doVirtMem()
	# doSwap()
	# doDiskIO()
	doProcess()

######################## MAIN ####################################
if __name__ == '__main__':
	print "Test PSUTIL!"
	# doNet()
	while True:
		doAllSys()
		time.sleep(5)
	sys.exit(0)

