#!/bin/bash

# Returns a summary of the cpu usage, with the program using the most cpu formatted:
# CPU: X.XX% | <program> X.XX%
# (Shortens process name so it at most maxCharacters long)


cpu_percentage=$(iostat | tail -1 | awk '{ print $4 + $5 }')

highest_cpu_process=$(ps -Arco pcpu,comm | head -2 | awk 'NR == 2 { print $2 "  " $1 "% " }')
shorten_name_script="$(dirname "$0")/process_name_shortener.awk"
highest_cpu_process=$(echo "$highest_cpu_process" | $shorten_name_script )

printf "CPU %s | %s\n" "${cpu_percentage}%" "$highest_cpu_process"
