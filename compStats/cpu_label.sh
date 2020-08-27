#!/bin/bash

# Returns a summary of the cpu usage, with the program using the most cpu formatted:
# CPU: X.XX% (<program> X.XX%)
# (Shortens process name so it at most maxCharacters long)


cpu_percentage=$(top -l 1 | grep -o "CPU usage: \d\+\.\d\+%" | sed 's/ usage://')

highest_cpu_process=$(ps -Arco pcpu,comm | head -2 | awk 'NR == 2 { print $2 "  " $1 "% " }')

shorten_name_script='
BEGIN {
    maxCharacters = 12
    shortenLength = 9
}
{
    processLength = length($1)
    if (processLength > maxCharacters) {
        print substr($1, 0, shortenLength) "..." $2 
    } else {
        print $0
    }
}
'
highest_cpu_process=$(echo $highest_cpu_process | awk "$shorten_name_script" )

printf "%s (%s)\n" "$cpu_percentage" "$highest_cpu_process"
