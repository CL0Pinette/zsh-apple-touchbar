#!/bin/bash

# Formats the battery percentage
# Formatted: 🔋 XX%

battery_percentage=$(pmset -g batt | grep -o "[0-9]\+%")

printf "🔋 %s\n" "$battery_percentage"

