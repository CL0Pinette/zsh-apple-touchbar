#!/bin/zsh

# Async updates wttr.in for the weather information
# Changes display based on if its daylight where you are to show a moon or sun

# =========== Configuration
update_interval=900     # In seconds
start_dynamic_keys=2    # Keys that update over time change start on this key onwards

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

# Takes normal args you'd give curl
quiet_curl() {
    curl -s $@ # 2> /dev/null
}

# Returns 1 if wttr is not working, 0 otherwise
wttr_working() {
    wttr_res=$(quiet_curl wttr.in/\?format="%d")
    if [ "$wttr_res" = "" ] || [ $(echo $wttr_res | awk '{ print $1 }') = 'Unknown' ]; then
        return 1
    else
        return 0
    fi
}

# Echoes 'day' if day, 'night' if night, and an empty string if wttr.in is down
is_day_or_night() {
    #echo 'in function???'
    sunset_time=$(quiet_curl wttr.in/\?format="%s")
    sunrise_time=$(quiet_curl wttr.in/\?format="%S")

    # Get times for now, sunrise and sunset
    epoch_time_now=$(date -j -f "%a %b %d %T %Z %Y" "`date`" "+%s")

    sunset_time=$(date | sed "s/[0-9][0-9]:[0-9][0-9]:[0-9][0-9]/$sunset_time/g")
    epoch_sunset=$(date -j -f "%a %b %d %T %Z %Y" "$sunset_time" "+%s")

    sunrise_time=$(date | sed "s/[0-9][0-9]:[0-9][0-9]:[0-9][0-9]/$sunrise_time/g")
    epoch_sunrise=$(date -j -f "%a %b %d %T %Z %Y" "$sunrise_time" "+%s")

    # If its after sunrise and before sunset, show a sun else a moon
    if (( $epoch_time_now > $epoch_sunrise )) && (( $epoch_time_now < $epoch_sunset )); then
        # Daytime
        is_day_or_night_res='day'
    else
        # Nighttime
        is_day_or_night_res='night'
    fi
}

# $1: Weather it is day or night
# Echoes empty string if wttr.in is down
get_weather_touchbar_info() {
    case $1 in
        'day')
            prefix="🔅"
            ;;
        'night')
            prefix=$(quiet_curl wttr.in/\?format="%m")
            ;;
        *)
            echo ''
            return 1
            ;;
    esac

    format_str='%l|%C+%c|%f|%w|%h'
    weather_curl_res=$(quiet_curl wttr.in\?format="$format_str")

    get_weather_touchbar_info_res="$prefix|$weather_curl_res"
}


# ========================

# Give PID to the caller
echo "$$" > $PID_pipe

# Create temporary loading text
create_key "$start_dynamic_keys" "Fetching the weather..." ''

while [ true ]; do
    if [ ! wttr_working ]; then
        echo 'no iternet'
        create_key "$start_dynamic_keys" "No Internet ):" ''
        continue
    fi

    #echo 'right before, it waits for stdin?'
    is_day_or_night
    get_weather_touchbar_info $is_day_or_night_res
    weather_str=$get_weather_touchbar_info_res

    # Parse Information
    touchbar_list=()

    solar_body=$(echo $weather_str | awk 'BEGIN { FS = "|" } ; { print $1 }')
    touchbar_list+=("$solar_body")

    location="📍 $(echo $weather_str | awk 'BEGIN { FS = "|" } ; { print $2 }')"
    touchbar_list+=("$location")

    weather=$(echo $weather_str | awk 'BEGIN { FS = "|" } ; { print $3 }')
    touchbar_list+=("$weather")

    temperature_feels_like=$(echo $weather_str | awk 'BEGIN { FS = "|" } ; { print $4 }')
    touchbar_list+=("$temperature_feels_like")

    wind=$(echo $weather_str | awk 'BEGIN { FS = "|" } ; { print $5 }')
    touchbar_list+=("$wind")

    humidity="💦 $(echo $weather_str | awk 'BEGIN { FS = "|" } ; { print $6 }')"
    touchbar_list+=("$humidity")

    # Update Key Labels
    start_index=$start_dynamic_keys
    for info in ${touchbar_list[@]}; do
        create_key "$start_index" "$info" ''
        start_index=$(( $start_index + 1 ))
    done

    sleep $update_interval
done
