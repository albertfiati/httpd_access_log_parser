#!/bin/bash

#cat http_logs.log | awk '{print $1 "\t " $10}' | grep "[0-9]$" | grep 129.16.226.160 | awk '{arr[$1]+=$2} END {for (i in arr) {print i,arr[i]}}'
#cat http_logs.log | awk '{print $1 "\t " $10}' | grep "[0-9]$" | awk '{arr[$1]+=$2} END {for (i in arr) {print i,arr[i]}}'

cat http_logs.log | awk '{print $1 "\t " $10}' | sort | grep "[0-9]$" | awk '{arr[$1]+=$2} END {for (i in arr) {print arr[i] "\t" i}}' | sort -nr | awk '{print $2 "\t" $1}'

#cat http_logs.log | awk '{print $1 "\t " $10}' | grep "[0-9]$" | uniq -c | sort -r

#129.16.226.160 18068920

#86043
#213.112.65.57	 861
#213.112.65.57	 82367
#213.112.65.57	 701
#213.112.65.57	 2114

#93692
#212.105.37.19	 2114
#212.105.37.19	 2936
#212.105.37.19	 4725
#212.105.37.19	 701
#212.105.37.19	 82367
#212.105.37.19	 849