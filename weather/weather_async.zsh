#!/bin/zsh

# Async updates wttr.in for the weather information
# Changes display based on if its daylight where you are to show a moon or sun

# =========== Configuration

update_interval=900 # In seconds

# =========== Handle args + source functions
cur_file="$0"
source "$(dirname $(dirname $cur_file))/functions.zsh"

PID_pipe="$1"

# =========== Setup trap behaviour
function cleanup() {
    exit 0
}
trap "cleanup" SIGTERM SIGHUP

# =========== Functions
script_dir="${0:A:h}"
# $1: script name relative to this script's directory (with fie extension)
function callScript() {
    echo $(. "$script_dir/$1")
}

# ========================

# Give PID to the caller
echo "$$" > $PID_pipe

# Returns 1 if wttr is not working, 0 otherwise
wttr_working() {
    wttr_res=$(curl -s wttr.in/\?format="%d")
    echo $wttr_res
    if [ "$wttr_res" = "" ] || [ $(echo $wttr_res | awk '{ print $1 }') = 'Unknown' ]; then
        return 1
    else
        return 0
    fi
}

# Echoes 'day' if day, 'night' if night, and an empty string if wttr.in is down
is_day_or_night() {
    if [ ! $(wttr_working) ]; then
        echo 2
        return 1
    fi

    sunset_time=$(curl -s wttr.in/\?format="%s")
    sunrise_time=$(curl -s wttr.in/\?format="%S")

    # Get times for now, sunrise and sunset
    epoch_time_now=$(date -j -f "%a %b %d %T %Z %Y" "`date`" "+%s")

    sunset_time=$(date | sed "s/[0-9][0-9]:[0-9][0-9]:[0-9][0-9]/$sunset_time/g")
    epoch_sunset=$(date -j -f "%a %b %d %T %Z %Y" "$sunset_time" "+%s")

    sunrise_time=$(date | sed "s/[0-9][0-9]:[0-9][0-9]:[0-9][0-9]/$sunrise_time/g")
    epoch_sunrise=$(date -j -f "%a %b %d %T %Z %Y" "$sunrise_time" "+%s")

    # If its after sunrise and before sunset, show a sun else a moon
    if (( $epoch_time_now > $epoch_sunrise )) && (( $epoch_time_now < $epoch_sunset )); then
        # Daytime
        echo 'day'
        return 0
    else
        # Nighttime
        echo 'night'
        return 0
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
            prefix=$(curl -s wttr.in/\?format="%m")
            ;;
        *)
            echo ''
            return 1
            ;;
    esac

    format_str='%C+%c+%f+%w+%h'
    weather_curl_res=$(curl -s wttr.in\?format="$format_str")

    echo "$prefix $weather_curl_res"
}

while [ true ]; do
    start_index=2

    if [ ! $(wttr_working) ]; then
        create_key "$start_index" "No Internet ):" ''
        continue
    fi

    time_of_day=$(is_day_or_night)
    weather_str=$(get_weather_touchbar_info $time_of_day)

    # Parse Information
    touchbar_list=()
    solar_body=$(echo $weather_str | awk '{ print $1 }')
    touchbar_list+=("$solar_body")

    location="📍 $(curl -s wttr.in\?format='%l')"
    touchbar_list+=("$location")

    weather=$(echo $weather_str | awk '{ print $2 " " $3 }')
    touchbar_list+=("$weather")

    temperature_feels_like=$(echo $weather_str | awk '{ print $4 }')
    touchbar_list+=("$temperature_feels_like")

    wind=$(echo $weather_str | awk '{ print $5 }')
    touchbar_list+=("$wind")

    humidity="💦 $(echo $weather_str | awk '{ print $6 }')"
    touchbar_list+=("$humidity")

    # Update Key Labels
    for info in ${touchbar_list[@]}; do
        create_key "$start_index" "$info" ''
        start_index=$(( $start_index + 1 ))
    done

    sleep $update_interval
done
