#!/bin/bash/

uso() {
	echo 'MirarV5 [-n cant_lineas] [-p patron] [-s separador] -f archivo_log'
}

if  [ $# -lt 1 ] || [ $# -gt 3 ]; then
	uso; exit 1
fi

n=
pattern=
file=
sep=";"
while getopts "n:p:hf:s:" opt
do
	case $opt in
                h)
                         uso; exit 1
                ;;
                n)
                        if [ $OPTARG -eq $OPTARG ] 2>/dev/null; then
				n="$OPTARG"
			else
				echo n debe ser un parametro numerico
				exit 1
			fi
                ;;
                p)
                        pattern="$OPTARG"
                ;;
		f)
			file="$OPTARG"
		;;
		s)
			sep="$OPTARG"
		;;
                ?)
                        uso; exit 1
                ;;
        esac
done
if [ -z $file ]; then
	echo 'Debe pasar -f con el nombre de un archivo de log'
	exit 1
fi
if [ ! -r $file ]; then
	echo 'El archivo no es valido para lectura'
	exit 1
fi

output=`cat $file`

if [ ! -z $n ]
then
	output=`echo "$output" | tail -n $n`
fi

if [ ! -z $pattern ]
then
	output=`echo "$output" | grep $pattern $file`
fi

entradas=`echo "$output"| sed s/$sep/"|"/g`

divider===================================
divider=$divider$divider

header="\n%6s %10s %10s %10s %12s\n"

width=43

printf "$header" "FECHA" "USUARIO" "ESTADO" "RESPONSABLE" "MENSAJE"

printf "%$width.${width}s\n" "$divider"

printf "%s" "$entradas" | while IFS= read -r line
do
	printf "%s\n" "$line"
done
