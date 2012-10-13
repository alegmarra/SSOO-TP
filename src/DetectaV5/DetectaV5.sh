#!/bin/bash

#DAEMON=> nohup ./DetectaV5.sh 0<&- 1>/dev/null 2>&1 &

ayuda () {

	echo "DAEMON=> nohup ./DetectaV5.sh 0<&- 1>/dev/null 2>&1 & "

}
validarFormato () {

	if [[ ${1##*/} =~ [[:alnum:]+]_[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]
	then
		return 0
	else 
		return 1 
	fi
}


validarSIS_ID () {

	id=${1##*/}

	num=`grep "^${id%_*};[^;]\+;[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\};*" ${MAEDIR}/sistemas | wc -l`

	if [[ $num  -gt 0 ]];then
		return 0
	else
		return 1
	fi

}

validarFecha () {

	local file=${1##*/}

	id=${file%_*}
	fecha=${file#*_}
	
	# Si cumple el formato de fecha (@TODO mejorar validacion)
	if [[ ${fecha} =~ ^[12][09][0-9]+-[01][0-9]-[0-3][0-9]$ ]]
	then
		
		fecha=${fecha//-/}
	
		# Si es una fecha menor al dia de hoy
		if [[ ${fecha} -le `date +"%Y%m%d"` ]]
		then

			reg=`grep "^${id%_*};[^;]\+;[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\};*" ${MAEDIR}/sistemas`
			
			regFechas=${reg#*;*;}
			alta=${regFechas%;*}
			baja=${regFechas#*;}

			# Si es mayor a la fecha de alta del sistema
			if [[ ${fecha} -ge ${alta//-/} ]]; 
			then
				if [[ ! -z "$baja" ]]; 
				then
					# Si es menor a la fecha de baja del sistema
					if [[ ${fecha} -le ${baja//-/} ]]; 
					then 
						return 0
					else
						return 1
					fi
				else
					return 0
				fi
			fi
		fi
	fi

	return 1

}


### MAIN ########

# Coloco paths DE PRUEBA, @TODO usar el path correcto
ARRDIR="./tests/arribos"
MAEDIR="./tests/maestros"
RECHDIR="./tests/rechazados"
ACEPDIR="./tests/aceptados"
BINDIR="./tests"
SLEEPTIME="2" #segundos


# Verificar si la inicializacion de ambiente
# se realizo anteriormente:
$BINDIR/IniciarV5.sh -inicializado > /dev/null
INICIALIZADO=$? # atrapo el codigo de retorno de IniciarV5
if [ $INICIALIZADO -eq 1 ]; then
        echo "El sistema no fue inicializado.
Debe inicializarlo antes con el comando $BINDIR/IniciarV5."

        exit 1
fi


# Chequeo de ejecución única del proceso. 
pName="DetectaV5.sh"

if [[ `ps -C "$pName" -o "pid=" | wc -l` -gt 2 ]]; then

	prevID=` ps -C "$pName" -o "pid=" ` 
	prevID=${prevID/[^0-9]*$$}
	echo ""$pName" ya se encuentra en ejecucion. Proceso $prevID "

	exit 1

fi

if [[ $1 == "-h" ]]; then 
	ayuda 
	exit 1
fi

# Inicio Loop Demonizado

while true; do

#Si hay archivos en la carpeta de arribos
arribos=`find "$ARRDIR" -maxdepth 1 -type f -regex ${ARRDIR%/}"/.*" | wc -l`

if [[ $arribos -gt 0 ]]; then

	for file in `find "$ARRDIR" -maxdepth 1 -type f -regex ${ARRDIR%/}"/.*"`
	do	
		validarFormato "$file"
		if [[ "$?" -eq 0  ]];then
			
			validarSIS_ID "$file"
			if [[ "$?" -eq 0  ]]; then

				validarFecha "$file"
				if [[ "$?" -eq 0  ]]; then
					
					$BINDIR/MoverV5.sh "$file" "$ACEPDIR"
					
					# Log de exito			
					$BINDIR/LoguearV5.sh -c "001" -f "$pname" -i "I"

				else
				# Fecha invalida
					$BINDIR/MoverV5.sh "$file" "$RECHDIR"
					# Log de rechazo. Fecha incorrecta
					$BINDIR/LoguearV5.sh -c "002" -f "$pname" -i "E"
				fi
		
			else
			# SIS_ID invalido
				$BINDIR/MoverV5.sh "$file" "$RECHDIR"
				# Log de rechazo. SIS_ID Inválido
				$BINDIR/LoguearV5.sh -c "003" -f "$pname" -i "E"
			fi
		else
		# Formato invalido
			$BINDIR/MoverV5.sh "$file" "$RECHDIR"
			# Log de rechazo. Formato de archivo Inválido
			$BINDIR/LoguearV5.sh -c "004" -f "$pname" -i "E"
		fi
	done
fi



aceptados=`find "$ACEPDIR" -maxdepth 1 -type f -regex ${ACEPDIR%/}"/.*" | wc -l`
 
if [[ $aceptados -gt 0 ]]; then

	pCallName="BuscarV5.sh"
	pID=`ps -C "$pCallName" -o "pid="`
	
	if [[ $pID -eq 0 ]]; then
		$BINDIR/$pCallName
	else 
		echo ""$pCallName" ya se encuentra en ejecucion. Proceso ${pID/$'\n'}"
	fi
		
fi

sleep "$SLEEPTIME"

done
