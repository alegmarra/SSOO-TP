#!/bin/bash

ayuda () {

	echo "DetenerV5 no recibe argumentos"

}

if [ ! -z $1 ]; then
	ayuda
	exit 1
fi


# CAMBIAR CAMBIAR CAMBIAR CAMBIAR
BINDIR=./testBin

for comando in `find "$BINDIR" -maxdepth 1 -type f -regex ${BINDIR%/}"/.*"`
do
	if [ ! ${comando##*/} = "StopD.sh" ]; then
		$BINDIR/StopD.sh ${comando##*/}
	fi
	
done

exit 0
