#!/bin/sh

mic=$(amixer sset Mic toggle | grep "%]" | grep "Left")

IFS=" "
set -- $mic; aux=${7#?}; mute=${aux%?}

echo "M:$mute" > /tmp/panel

