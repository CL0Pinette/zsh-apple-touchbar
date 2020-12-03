#!/bin/bash

# Returns CPU 1m load from iostat
# Formatted: CPU X.XX

cpu_load=$(iostat -n 0 | tail -1 | awk '{ print $4 }')

printf "Load: %s\n" "$cpu_load"

