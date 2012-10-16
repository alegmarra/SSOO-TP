#!/bin/bash

ayuda () {

	echo "DetenerV5 no recibe argumentos"

}

if [ ! -z $1 ]; then
	ayuda
	exit 1
fi


for comando in `find "$BINDIR" -maxdepth 1 -type f -regex ${BINDIR%/}"/.*"`
do
	if [ ! ${comando##*/} = "StopD.sh" ]; then
		$BINDIR/StopD.sh ${comando##*/}
	fi
	
done

PATH=`echo ${PATH} | sed "s_\:${BINDIR}__g"`

VARIABLES=(GRUPO CONFDIR BINDIR MAEDIR ARRIDIR ACEPDIR RECHDIR PROCDIR REPODIR LOGDIR LOGEXT LOGSIZE)

for i in "${VARIABLES[@]}"
do	
	unset `echo ${i}`
done

