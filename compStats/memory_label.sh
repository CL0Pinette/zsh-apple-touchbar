#!/bin/bash

# Returns a summary of the memory usage formatted:
# MEM X.XXG/X.XXG (SWP X.XXM/X>XXM)
# (will omit the SWP portion if swap is 0)

memory_icon="💭"

memory_info=$(vm_stat | ./vm_stat_formatter.awk)
memory_message="MEM $memory_info"

swap_info=$(sysctl vm.swapusage | awk '$7 != "0.00M" { print $7 "/" $4 }')
if [ ! -z "$swap_info" ]; then
    swp_message=" (SWP: $swap_info)"
fi

final_message="$memory_message$swp_message"

printf "$final_message\n"
