#!/bin/sh
level="$(cat /sys/class/power_supply/BAT1/capacity)"
state="$(cat /sys/class/power_supply/BAT1/status)"
echo "B:$level:$state" > /tmp/panel

