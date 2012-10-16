#!/bin/bash

ayuda () {
	echo "StopD.sh <NombreProceso.sh>"
}

# Chequeo de ejecución del  proceso. 

if [ "$#" -lt 1 ]; then 
	ayuda
	exit 1
fi


pName="$1"

if [ "$1" = "-h" ]; then
	ayuda
	exit 1
fi


for ID in ` ps -C "$pName" -o "pid=" `
do
	kill -9 $ID
done

exit 0
