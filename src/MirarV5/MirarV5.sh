#!/bin/bash

uso() {
	echo 'MirarV5 [-n cant_lineas] [-p patron] [-s separador] -f archivo_log'
}

if  [ $# -lt 1 ]; then
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
                \?)
                        echo "uso incorrecto\n"; uso; exit 1
                ;;
        esac
done
shift $(($OPTIND - 1))
if [ -z $file ]; then
	echo 'Debe pasar -f con el nombre de un archivo de log'
	exit 1
fi
if [ ! -r $file ]; then
	echo 'El archivo no es valido para lectura'
	exit 1
fi

output=`cat $file`

if [ ! -z $pattern ]
then
	output=`echo "$output" | grep $pattern $file`
fi

if [ ! -z $n ]
then
        output=`echo "$output" | tail --lines=$n`
fi


no=`echo $output | awk -F"$sep" -v l=\`echo $output | awk 'END{print NR}'\` '
{A[NR]=length($1)" "length($2)" "length($3)" "length($4)" "length($5)}
END{for(i=0;i<l;++i)
{split(A[i],B," ");
{if(B[1]>max1){max1=B[1]}}
{if(B[2]>max2){max2=B[2]}}
{if(B[3]>max3){max3=B[3]}}
{if(B[4]>max4){max4=B[4]}}
{if(B[5]>max5){max5=B[5]}}
}{print max1" "max2" "max3" "max4" "max5}}'`
IFS=^M
echo FECHA USR EST RESP MENSAJE | awk -v var="$no" '{split(var,A," ")}{printf "%-"A[1]"s %-"A[2]"s %-"A[3]"s %-"A[4]"s %-"A[5]"s\n",$1,$2,$3,$4,$5}'
echo $output | awk -F"$sep" -v var="$no" '{split(var,A," ")}{printf "%-"A[1]"s %-"A[2]"s %-"A[3]"s %-"A[4]"s %-"A[5]"s\n",$1,$2,$3,$4,$5}'
