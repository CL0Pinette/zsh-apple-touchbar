#!/bin/zsh

# Asynchronously updates the touchbar using a script that runs in the background
#
# $1: Script name
#   Script name string used to determine what to show on the touchbar. Should print lines to stdout, where each
#   line represents one button to be used
#
# $2: Refresh interval time
#   Integer time period (in seconds) between calling the script for an updated touchbar string
#
# $3: Update interval time
#   Integer time period (in seconds) between refreshing the touchbar buttons.
#
# $4: Index to start display
#   Integer index to start displaying touchbar widgets. (1) corresponds to the first button.
#   Typically want 2, so the first button is the back icon.
#
# $5: Name of the PID pipe
#   FIFO pipe file name used to give the caller the PID of this process

# ========== Input args
script_name="$1"
refresh_interval="$2"
update_interval="$3"
start_display_index="$4"
PID_pipe="$5"

# ========== Setup trap behaviour
cleanup() {
    exit 0
}
trap "cleanup" SIGTERM SIGHUP

# =========== Sourcing functions and passing PID
cur_file="$0"
source "$(dirname $cur_file)/functions.zsh"

echo "$$" > "$PID_pipe"

# ========== Helper Functions
get_touchbar_string() {
    $script_name
}

# $1: String parsed for each touchbar key
write_keys() {
    touchbar_input="$1"

    touchbar_list=()
    for section in "${(f)touchbar_input}"; do
        touchbar_list+=("$section")
    done

    cur_index="$start_display_index"
    for info in ${touchbar_list[@]}; do
        create_key "$cur_index" "$info" ''
        cur_index=$(( $cur_index + 1 ))
    done
}

# ========== Showing Labels

create_key "$start_display_index" "Loading..." ''

current_update_time=$update_interval
current_refresh_time=$refresh_interval

while true; do
    # Update Touchbar string
    if (( current_refresh_time >= refresh_interval )); then
        current_refresh_time=0
        touchbar_string=$(get_touchbar_string)
    fi

    # Update Touchbar itself
    if (( current_update_time >= update_interval )); then
        current_update_time=0
        write_keys "$touchbar_string"
    fi

    # Sleeping
    sleep "$update_interval"
    current_update_time=$(( current_update_time + update_interval ))
    current_refresh_time=$(( current_refresh_time + update_interval ))
done
