#!/bin/bash

# Returns disk i/o from iostat
# Formatted: I/O X.XX MB/s

io_mb_per_second=$(iostat | awk 'NR == 3 { print $3 }')

printf "I/O %s MB/s\n" $io_mb_per_second

