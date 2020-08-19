#!/bin/bash

# Returns the process from top with highest cpu usage. Shortens process name so it at most $max_chars long
# Formatted: <Process> (X.XX%)

most_cpu_process=$(ps -Arco pcpu,comm | head -2 | awk 'NR == 2 { print $2 " (" $1 "%)" }')

shorten_script='
BEGIN {
    maxCharacters = 12
    shortenLength = 9
}
{
    processLength = length($1)
    if (processLength > maxCharacters) {
        print substr($1, 0, shortenLength) "... (" $2 ")"
    } else {
        print $0
    }
}
'
most_cpu_process=$(echo $most_cpu_process | awk "$shorten_script" )

printf "%s\n" "$most_cpu_process"
