#!/bin/bash

num=${1#*_}
num=${num%_*}

if [[ -e "$2" ]]; then
	MAX=$(head -n 1 "$2")
else
	MAX=0
fi


if [[ "$num" -gt "$MAX" ]]; then
	echo "$num" > "$2"
fi


