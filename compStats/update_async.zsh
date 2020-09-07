#!/bin/zsh

# Updates the touchbar in the background, setting touchbar elements to reflect status of computer
# First Arguement is the name of a pipe to transfer the PID of this process

# =========== Configuration

update_interval=5 # In seconds
start_dynamic_keys=2 # Keys that update over time change start on this key onwards

# =========== Handle args + source functions
cur_file="$0"
source "$(dirname $(dirname $cur_file))/functions.zsh"

PID_pipe="$1"

# =========== Setup trap behaviour
function comp_cleanup() {
    exit 0
}
trap "comp_cleanup" SIGTERM SIGHUP

# =========== Functions
script_dir="${0:A:h}"
# $1: script name relative to this script's directory (with fie extension)
function callScript() {
    echo $(. "$script_dir/$1")
}

# ========================

# Create temporary loading text
create_key "$start_dynamic_keys" "Loading..." ''

# Give PID to the caller
echo "$$" > $PID_pipe

# Check if 'istats' is available for cpu temperature
istats_available=0
if command -v  istats &> /dev/null; then
    istats_available=1
fi

while [ true ]; do
    # Put Info for Labels into a list
    touchbar_list=()

    battery_percentage=$(callScript "battery_label.sh")
    touchbar_list+=("$battery_percentage")

    cpu_stats=$(callScript "cpu_label.sh")
    touchbar_list+=("$cpu_stats")

    cpu_load=$(callScript "cpu_load_label.sh")
    touchbar_list+=("$cpu_load")

    mem_stats=$(callScript "memory_label.sh")
    touchbar_list+=("$mem_stats")

    io_stats=$(callScript "io_label.sh")
    touchbar_list+=("$io_stats")

    if (( $istats_available )); then
        cpu_temp=$(callScript "cpu_temp_label.sh")
        touchbar_list+=("$cpu_temp")
    fi


    # Update Key Labels
    start_index=$start_dynamic_keys
    for info in ${touchbar_list[@]}; do
        create_key "$start_index" "$info" ''
        start_index=$(( $start_index + 1 ))
    done

    # Wait for next update
    sleep $update_interval
done
