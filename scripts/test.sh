#!/bin/bash
domIDs=(2 3)
xtotal=${#domIDs[@]}
echo "The number of domains is ${xtotal}"
for (( count=0; count<${xtotal}; count++ )); do
	echo "Doing domain ${domIDs[$count]}"
done

