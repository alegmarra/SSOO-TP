#! /bin/bash

#forma correcta de uso
uso() {
	echo 'LoguearV5 -c ERRCODE -f CALLFUNC -i ERRSTAT [optionals]'
}

# aca vendria la parte de manejo de parametros

if [ $# -lt 4 ]
then
	uso
	exit 1
fi

errcode=
errstat=
cmdname=
sep=";"

while getopts "c:f:i:hs:" opt
do
	case $opt in
		h)
			 uso; exit 1
		;;
		c)
			errcode=$OPTARG
		;;
		f)
			cmdname=$OPTARG
		;;
		i)
			errstat=$OPTARG
		;;
		s)
			sep=$OPTARG
		;;	
		?)
			uso; exit 1
		;;
	esac
done

if [ [ -z $errcode ] || [ -z $cmdname ] || [ -z $errstat ] ]; then
	echo "error en los parametros\n"
	exit 1
fi
if [ -z $LOGDIR ]; then
	LOGDIR=$GRUPO/logdir
fi
if [ -z $LOGEXT ]; then
	LOGEXT="log"
if [ ! -d $LOGDIR ]; then
	mkdir $LOGDIR
fi

output="$cmdname.$LOGEXT"
mensaje=`grep $errcode ListaErrores`
fecha=`date +"%D"`
usr=`gawk '{print $1}' FS=" "`

printf "%s$sep%s$sep%s$sep%s$sep%120s\n" $fecha $usr $errstat $cmdname $mensaje >>$LOGDIR/$output

