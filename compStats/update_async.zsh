#!/bin/zsh

# Updates the touchbar in the background, setting touchbar elements to reflect status of computer
# First Arguement is the name of a pipe to transfer the PID of this process

function cleanup() {
    exit 0
}

trap "cleanup" SIGTERM SIGHUP

cur_file="$0"
source "$(dirname $(dirname $cur_file))/functions.zsh"

PID_pipe="$1"

# In seconds
update_interval=1

# Give PID to the caller
echo "$$" > $PID_pipe

while [ true ]; do

    # Info for Labels
    battery_percentage=$(. "${0:A:h}/battery_label.sh")

    cpu_stats=$(. "${0:A:h}/cpu_label.sh")
    most_cpu_process=$(. "${0:A:h}/cpu_process_label.sh")
    cpu_load=$(. "${0:A:h}/cpu_load_label.sh")

    mem_stats=$(. "${0:A:h}/memory_label.sh")
    most_mem_process=$(. "${0:A:h}/mem_process_label.sh")

    io_stats=$(. "${0:A:h}/io_label.sh")


    # Update Key Labels
    create_key 2 "$battery_percentage" ''

    create_key 3 "$cpu_stats ($most_cpu_process)" ''
    create_key 4 "$cpu_load" ''

    create_key 5 "$mem_stats ($most_mem_process)" ''

    create_key 6 "$io_stats" ''

    # Wait for next update
    sleep $update_interval
done
