#!/bin/zsh

# Updates the touchbar in the background, setting touchbar elements to reflect status of computer

tempfile=$1

cur_file="$0"
source "$(dirname $(dirname $cur_file))/functions.zsh"

# In seconds
update_interval=1

while [ -f "$tempfile" ]; do
    echo "update_async running"

    # Info for Labels
    cpu_stats=$(. "${0:A:h}/cpu_label.sh")
    mem_stats=$(. "${0:A:h}/memory_label.sh")

    # echo "------"
    # echo $cpu_stats
    # echo $mem_stats


    # Create Keys

    create_key 2 "$cpu_stats" ''
    create_key 3 "$mem_stats" ''


    # Wait for next update
    sleep $update_interval
done

echo "Done updating async"
