#!/bin/bash

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

## Run this benchmark on the Guest machines ##
benchCmd="./getScaleFactor"

