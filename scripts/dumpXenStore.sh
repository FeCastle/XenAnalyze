#!/bin/bash

function dumpkey() {
   local param=${1}
   local key
   local result
   result=$(xenstore-list ${param})
   if [ "${result}" != "" ] ; then
      for key in ${result} ; do dumpkey ${param}/${key} ; done
     else
      echo -n ${param}'='
      xenstore-read ${param}
   fi
}

for key in /vm /local/domain /tool ; do dumpkey ${key} ; done

