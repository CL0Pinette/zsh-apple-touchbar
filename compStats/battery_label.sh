#!/bin/bash

# Formats the battery percentage
# Formatted: 🔋 XX%


pmset=$(pmset -g batt)

case $(printf "%s" "$pmset" | grep -o "'.*'") in
    "'Battery Power'")
        power_icon='🔋'
        ;;
    "'AC Power'")
        power_icon='🔌'
        ;;
    *)
        power_icon='❓'
        ;;
esac

battery_percentage=$(pmset -g batt | grep -o "[0-9]\+%")

printf "%s %s\n" "$power_icon" "$battery_percentage"
