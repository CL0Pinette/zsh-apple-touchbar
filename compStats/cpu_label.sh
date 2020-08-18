#!/bin/bash

# Returns a summary of the cpu usage formatted:
# CPU: X.XX%


# CPU usage: top -l $num | grep "CPU usage"

cpu_percentage=$(top -l 1 | grep -o "CPU usage: \d\+\.\d\+%" | sed 's/ usage://')

printf "%s %s\n" $cpu_percentage
