#!/bin/bash

ayuda () {
	echo "StopD.sh <NombreProceso>"
}


if [ "$#" -lt 1 ] || [ "$1" = "-h" ]; then 
	ayuda
	exit 1
fi


pName="$1"

for ID in ` ps -C "${pName}" -o "pid=" `
do
	kill -9 ${ID}
done

exit 0
