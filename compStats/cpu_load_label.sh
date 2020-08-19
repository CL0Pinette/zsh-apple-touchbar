#!/bin/bash

# Returns CPU load from top
# Formatted: CPU X.XX

cpu_load=$(top -l 1 | grep "Load Avg:" | awk '{ print $4 }' | sed 's/,//g')

printf "CPU Load: %s\n" $cpu_load

