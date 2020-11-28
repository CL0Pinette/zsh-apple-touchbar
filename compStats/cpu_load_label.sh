#!/bin/bash

# Returns CPU load from top
# Formatted: CPU X.XX

cpu_load=$(iostat | tail -1 | awk '{ print $7 }')

printf "CPU Load: %s\n" "$cpu_load"

