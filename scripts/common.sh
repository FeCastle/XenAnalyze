#!/bin/bash
XENSTORED_PATH=/proc/xen/xenbus
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
export XENSTORED_PATH
export LD_LIBRARY_PATH

XENSTORE=xenstore
XENSTORE_READ=${XENSTORE}-read
XENSTORE_LIST=${XENSTORE}-list
XENSTORE_WRITE=${XENSTORE}-write

## Get some properties for the domain ##
myName=$(${XENSTORE_READ} name)
vmPath=$(${XENSTORE_READ} vm)
myUUID=$(${XENSTORE_READ} ${vmPath}/uuid)
targetMem=$(${XENSTORE_READ} memory/target)
domid=$(${XENSTORE_READ} domid)

## Keys for guests xenstore to do things ##
dataCollect="data/analysis/collect"   # Start/stop collecting statistics
benchmark="data/analysis/benchmark"   # Generate a load

## Default - Run this benchmark on the Guest machines ##
benchCmd="./getScaleFactor"

## Guest Machines DomIDs to run ##
domIDs=(2)
