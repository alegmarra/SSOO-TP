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

# TODO: limpiar estas variables cuando este hecha la parte de IniciarV5
GRUPO="."
LOGSIZE=2000000


while getopts c:f:i:hs: opt
do 
	case "$opt" in
		h)
			uso; exit 1;;
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
		\?)
			uso; exit 1
	esac
done
shift $(($OPTIND - 1))
if  [ -z $errcode ] || [ -z $cmdname ] || [ -z $errstat ]; then
	echo error en los parametros
	exit 1
fi
if [ -z $LOGDIR ]; then
	LOGDIR=$GRUPO/logdir
fi
if [ -z $LOGEXT ]; then
	LOGEXT="log"
fi
if [ ! -d $LOGDIR ]; then
	mkdir $LOGDIR
fi

if [ ! -z $LOGSIZE ]; then
	LOGSIZE=100000
fi

output="$cmdname.$LOGEXT"

if [ -r $LOGDIR/$output ] && [ `stat -c%s $LOGDIR/$output` -gt $LOGSIZE ]; then
	tail -n `expr `wc -l $LOGDIR/$output`/2` > $LOGDIR/$output
	sh LoguearV5.sh -c 1 -f $cmdname -i A
fi


mensaje=$(printf "$(grep "$errcode" ListaErrores)" $@)
ret=$?
printf "ret = %s\n" $ret
if [ $ret -ne 0 ]; then
	echo "faltan argumentos para el mensaje\n"
	exit 1
fi
fecha=`date +"%D"`
usr=`who | awk '{print $1}' FS=" "`
usr=`echo ${usr%%\\*}`
printf "usr = %s\n" "$usr"
printf "%s$sep%s$sep%s$sep%s$sep%s\n" "$fecha" "$usr" "$errstat" "$cmdname" "$mensaje" >>$LOGDIR/$output

exit 0
