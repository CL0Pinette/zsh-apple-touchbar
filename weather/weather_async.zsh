#!/bin/zsh

# Async updates wttr.in for the weather information
# Changes display based on if its daylight where you are to show a moon or sun

# =========== Configuration
update_interval=5     # In seconds
refresh_interval=900
start_dynamic_keys=2    # Keys that update over time change start on this key onwards
wttr_py="${0:A:h}/wttr.py"

# =========== Handle args + source functions
cur_file="$0"
source "$(dirname $(dirname $cur_file))/functions.zsh"

PID_pipe="$1"

# =========== Setup trap behaviour
function weather_cleanup() {
    exit 0
}
trap "weather_cleanup" SIGTERM SIGHUP

# =========== Functions
function wttr_working {
    echo "$($wttr_py --check)"
}

function get_touchbar_string {
    echo "$($wttr_py --info)"
}

# ========================

# Give PID to the caller
echo "$$" > $PID_pipe

# Create temporary loading text
create_key "$start_dynamic_keys" "Fetching the weather..." ''

cur_time=$refresh_interval
while [ true ]; do

    if (( $cur_time >= $refresh_interval )); then
        cur_time=0

        if [ $(wttr_working) = "unavailable" ]; then
            create_key "$start_dynamic_keys" "No Internet ):" ''
            continue
        else
            touchbar_string=$(echo "$($wttr_py --info)")

            # Parse Information
            touchbar_list=()

            for section in "${(f)touchbar_string}"; do
                touchbar_list+=("$section")
            done

            # Update Key Labels
            start_index=$start_dynamic_keys
            for info in ${touchbar_list[@]}; do
                create_key "$start_index" "$info" ''
                start_index=$(( $start_index + 1 ))
            done
        fi
    fi

    sleep $update_interval
    cur_time=$(echo "$cur_time + $update_interval" | bc)
done
