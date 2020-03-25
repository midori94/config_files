#!/bin/sh

master=$(amixer sget Master | grep "%]")
speaker=$(amixer sget Speaker | grep "Left" | grep "%]")

IFS=" "
set -- $master; aux=${4#?}; volume=${aux%??}
set -- $speaker; aux=${7#?}; mute=${aux%?}

echo "S:$volume:$mute" > /tmp/panel

