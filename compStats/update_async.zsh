#!/bin/zsh

# Updates the touchbar in the background, setting touchbar elements to reflect status of computer
# First Arguement is the name of a pipe to transfer the PID of this process

function cleanup() {
    echo "Done"
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
    cpu_stats=$(. "${0:A:h}/cpu_label.sh")
    mem_stats=$(. "${0:A:h}/memory_label.sh")

    # Update Key Labels
    create_key 2 "$cpu_stats" ''
    create_key 3 "$mem_stats" ''

    # Wait for next update
    sleep $update_interval
done
