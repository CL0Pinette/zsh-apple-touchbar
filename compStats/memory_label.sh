#!/bin/bash

# Returns a *rough* summary of the memory usage, with the process with highest memory usage formatted:
# MEM X.XXG/X.XXG (SWP X.XXM/X>XXM) (Process X.XX%)
# (will omit the SWP portion if swap is 0)

# ========== Memory Usage
vm_formatter_script="$(dirname $0)/vm_stat_formatter.awk"
memory_proportion=$(vm_stat | $vm_formatter_script)
swap_info=$(sysctl vm.swapusage | awk '
$7 != "0.00M"   { swp_proportion = $7 "/" $4 }
END             {
                    if (length(swp_proportion) != 0) {
                        print "(SWP: " swp_proportion ")"
                    }
                }
')
memory_summary="MEM $memory_proportion $swp_message"


# ========= Highest Memory Process
most_mem_process=$(ps -Arco pmem,comm | head -2 | awk 'NR == 2 { print $2 "  " $1 "%" }')
shorten_script='
BEGIN {
    maxCharacters = 12
    shortenLength = 9
}
{
    processLength = length($1)
    if (processLength > maxCharacters) {
        print substr($1, 0, shortenLength) "... " $2
    } else {
        print $0
    }
}
'
most_mem_process=$(echo $most_mem_process | awk "$shorten_script" )



printf "%s (%s)\n"  "$memory_summary" "$most_mem_process"
