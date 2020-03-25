#!/bin/sh

PIPE=/tmp/panel
BAR_PARAMS=(
	"-f \"xos4 Terminus\" "
	"-f \"Ionicons\" "
	"-a 20"
	"-u 1 "
	"-B \"#d0000000\" "
	"-F \"#ffffff\" "
)
BAR() {
	AUX=(
		"%{l} "
		"\uf1ef "
		#"$WORKSPACE "
		"%{c}"     
		"$MESSAGE " 
		"%{r} "     
		"%{A:mic.sh:}$ICON4%{A} "
		"| $ICON3 $BACKLIGHT% "
		"| $ICON2 $VOLUME% "
		"| $ICON1 $BATTERY% "
		"| $DATE "
		"| $TIME "
	)
	echo -e ${AUX[*]}
}

battery() {
	while true; do
		level="$(cat /sys/class/power_supply/BAT1/capacity)"
		state="$(cat /sys/class/power_supply/BAT1/status)"
		echo "B:$level:$state"
		sleep 60
	done
}

clock() {
	while true; do
		echo 	"T:$(date +"%b:%a:%d:%I:%M:%p")"
		sleep 60
	done
}

workspace() {
	bspc subscribe report	
}

ICON3="\uf4b7"

make_panel() {
	while read -r line; do
		IFS=":"
		set -- $line
		case $1 in
			T)
				DATE="$2 $3 $4"
				TIME="$5:$6 $7"
				;;
			B)
				BATTERY="$2"	
				BAT_STATE="$3"
				ICON1="%{F#ff0000}\uf295%{F-}"
				[ $BATTERY -ge 10 ] && ICON1="%{F#ff7f00}\uf296%{F-}"
				[ $BATTERY -ge 30 ] && ICON1="%{F#ffff00}\uf296%{F-}"
				[ $BATTERY -ge 50 ] && ICON1="%{F#bfff00}\uf296%{F-}"
				[ $BATTERY -ge 70 ] && ICON1="%{F#00ff00}\uf296%{F-}"
				[ $BAT_STATE = "Charging" ] && ICON1="\uf294"
				;;
			S)
				VOLUME="$2"
				MUTE="$3"
				ICON2="\uf123"
				[ $MUTE = "off" ] && ICON2="\uf3a2"
				;;
			L)
				BACKLIGHT="$2"
				;;

			M)
				MIC="$2"
				ICON4="\uf32b"
				[ $MIC = "on" ] && ICON4="\uf32c"
				;;
			W*)
				WORKSPACE=
				while [ $1 ]; do
					item=$1
					id=${item#?}
					case $1 in
						[fFoOuU]*)
							ICON="\uf1f6"
							[[ $item == o* || $item == O* ]] && ICON="\uf1f7"
							[[ $id == "I" ]] && ICON="\uf30c"
							[[ $id == "II" ]] && ICON="\uf301"
							[[ $id == "IX" ]] && ICON="\uf146"
							[[ $id == "X" ]] && ICON="\uf24c"	

							desktop="%{A:bspc desktop -f ${id}:}$ICON%{A}"
							[[ $item == F* || $item == O* ]] && desktop="%{+u}${desktop}%{-u}"

							WORKSPACE="$WORKSPACE $desktop"
					esac
					shift
				done
				;;
		esac
		echo -e "%{l} %{F#ff0000}%{A:systemctl hibernate:}\uf359%{A}%{F-}  $WORKSPACE%{r}%{+u}%{A:mic.sh:}$ICON4%{A}%{-u}  %{+u}$ICON3 ${BACKLIGHT}%%{-u}  %{+u}$ICON2 ${VOLUME}%%{-u}  %{+u}$ICON1 ${BATTERY}%%{-u}  %{+u}$DATE%{-u} %{+u}$TIME%{-u} "
	done
}


[ -e $PIPE ] && rm $PIPE
mkfifo $PIPE

pgrep lemonbar && pkill lemonbar

mic.sh &
sound.sh &
backlight.sh &

battery > $PIPE &
clock > $PIPE &
workspace > $PIPE &

make_panel < $PIPE \
	| eval lemonbar -p ${BAR_PARAMS[*]} \
	| while read line; do eval $line; done &
