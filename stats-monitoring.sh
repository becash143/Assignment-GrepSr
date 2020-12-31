#!/bin/bash

## Script to Monitor Sys STATS
echo "Server_Name, CPU, Memory, Disk" > /tmp/cpu-mem-swap.csv
for server in `more ./server-list.txt`
do
cpu=$(top -bn1 | grep load | awk '{printf "CPU Load: %.2f\n", $(NF-2)}')
mem=$(free -m | awk 'NR==2{printf "Memory Usage: %s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }')
df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }' | while read output;
do
  echo $output
  used=$(echo $output | awk '{ print $1}' | cut -d'%' -f1  )
  partition=$(echo $output | awk '{ print $2 }' )
  if [ $usep >= 80 ]; then
	    echo "The partition \"$partition\" on $(hostname) has used $used% at $(date)" >> /tmp/diskused.csv 
  fi
done
echo "$server, $cpu, $mem" >> /tmp/cpu-mem-disk.csv
done
echo "CPU and Memory Report for `date +"%B %Y"`" 
