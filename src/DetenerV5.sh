#!/bin/bash

BINDIR=./testBin

for comando in `find "$BINDIR" -maxdepth 1 -type f -regex ${BINDIR%/}"/.*"`
do
	if [ ! ${comando##*/} = "StopD.sh" ]; then
		$BINDIR/StopD.sh ${comando##*/}
	fi
	
done

exit 0
