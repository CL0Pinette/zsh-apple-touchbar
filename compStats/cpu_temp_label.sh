#!/bin/bash

# Returns the cpu temp, with an emoji to contextualize how hot that is
# Format:
# CPU temp <emoji> XX.XX%
# ! Uses the gem istats to get the CPU temperature

# If istats isn't in path/installed, exit with error code
if [ -z $(command -v "istats") ]; then
    exit 1
fi

# CPU temperature mappings to emoji
cold='❄️'
cool='🆒'
medium='😌'
warm='😰'
hot='🥵'

# Temperature Thresholds (Celsuis)
cold_limit=40       # ..<cold_limit
cool_limit=60       # cold_limit..cool_limit
medium_limit=70     # cool_limit..medium_limit
warm_limit=80       # medium_limit..warm_limit
                    # warm_limit.. (hot)


# Echoes 1 if Temperature is in the range (- inf)..(upper limit)
# Echoes 0 otherwise
# $1: Temperature
# $2: Upper Limit
temperatureLessThanLimit() {
    if (( $(echo "$1 <= $2" | bc -l) )); then
        echo 1
    else
        echo 0
    fi
}

# Echoes 1 if Temperature is in the range (lower limit)..<(upper limit)
# Echoes 0 otherwise
# $1: Temperature
# $2: Lower Limit
temperatureBetweenLimits() {
    if (( $(echo "$1 >= $2 || $1 < $3" | bc -l)  )); then
        echo 1
    else
        echo 0
    fi
}


# Echoes 1 if Temperature is in range (lower limit)..(+ inf)
# Echoes 0 otherwise
# $1: Temperature
# $2: Lower Limit
temperatureGreaterThanLimit() {
    if (( $(echo "$1 >= $2" | bc -l) )); then
        echo 1
    else
        echo 0
    fi
}

# Get CPU temp
cpu_temp_celsius=$(istats | awk '$1 " " $2 == "CPU temp:" { print $3 }')
temperature=$(echo "$cpu_temp_celsius" | grep -Eo '[0-9]+\.[0-9]+' )

# Determine which icon to assign the CPU temperature
if (( $(temperatureLessThanLimit "$temperature" $cold_limit) )); then
    cpu_temp_icon=$cold
elif (( $(temperatureBetweenLimits "$temperature" $cold_limit $cool_limit) )); then
    cpu_temp_icon=$cool
elif (( $(temperatureBetweenLimits "$temperature" $cool_limit $medium_limit) )); then
    cpu_temp_icon=$medium
elif (( $(temperatureBetweenLimits "$temperature" $medium_limit $warm_limit) )); then
    cpu_temp_icon=$warm
elif (( $(temperatureGreaterThanLimit "$temperature" $warm_limit) )); then
    cpu_temp_icon=$hot
fi

# Echo result
echo "CPU Temp: $cpu_temp_icon $cpu_temp_celsius"
