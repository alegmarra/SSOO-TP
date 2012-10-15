#!/bin/bash

#####################################################################
# DetectaV5.sh
# 
# El propósito de este comando es detectar la llegada de archivos al directorio ARRIDIR, efectuar la
# validación del nombre del archivo que detecta y ponerlo a disposición del siguiente paso. Si el
# archivo no es válido, debe rechazarlo.
#
# Script tipo Demonio
#
#####################################################################

####################################################################
# Mensaje de ayuda en uso del comando
####################################################################

ayuda () {

	echo "DAEMON=> nohup ./DetectaV5.sh 0<&- 1>/dev/null 2>&1 & "

}


####################################################################
# validarFormato
# @brief Verifica que el nombre del archivo tenga los tipos y cantidad de 
#        campos correctos
# @arg1  Nombre de archivo
####################################################################

validarFormato () {

	if [[ ${1##*/} =~ [[:alnum:]+]_[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]
	then
		return 0
	else 
		return 1 
	fi
}


####################################################################
# validarSIS_ID
# @brief Verifica que exista el sistema referenciado en el nombre 
#        
# @arg1  Nombre de archivo con formato válido
####################################################################

validarSIS_ID () {

	id=${1##*/}

	num=`grep "^${id%_*};[^;]\+;[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\};*" ${MAEDIR}/sistemas | wc -l`

	if [[ $num  -gt 0 ]];then
		return 0
	else
		return 1
	fi

}

####################################################################
# validarFecha
# @brief Verifica que la fecha sea válida y se corresponda con el rango
#	 de fechas que maneja el sistema SIS_ID 
#        
# @arg1  Nombre de archivo con formato válido
####################################################################

validarFecha () {

	local file=${1##*/}

	id=${file%_*}
	fecha=${file#*_}
	
	# Si cumple el formato de fecha 
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
						# Fecha valida
						return 0
					else
						# Fecha Invalida
						return 1
					fi
				else
					# El sistema no tiene fecha de baja, es valida
					return 0
				fi
			fi
		fi
	fi

	return 1
}


####################################################################
# MAIN 
####################################################################

##
# En caso de comando de ayuda
##
if [[ $1 == "-h" ]]; then 
	ayuda 
	exit 1
fi

##
# Coloco paths DE PRUEBA
# @TODO usar el path correcto
##
ARRDIR="./tests/arribos"
MAEDIR="./tests/maestros"
RECHDIR="./tests/rechazados"
ACEPDIR="./tests/aceptados"
BINDIR="./tests"
SLEEPTIME="2" #segundos


##
# Verificar si la inicializacion de ambiente
# se realizo anteriormente:
##
$BINDIR/IniciarV5.sh -inicializado > /dev/null
INICIALIZADO=$? # atrapo el codigo de retorno de IniciarV5
if [ $INICIALIZADO -eq 1 ]; then
        echo "El sistema no fue inicializado.
	      Debe inicializarlo antes con el comando $BINDIR/IniciarV5."

        exit 1
fi



##
# Chequeo de ejecución única del proceso. 
##

pName="DetectaV5.sh"

if [[ `ps -C "$pName" -o "pid=" | wc -l` -gt 2 ]]; then

	prevID=` ps -C "$pName" -o "pid=" ` 
	prevID=${prevID%[^0-9]*}
	echo "DetectaV5 ya se encuentra en ejecucion. Proceso $prevID "

	exit 1

fi


##
# Inicio Loop Demonizado
##
while true; do


# Si hay archivos en la carpeta de arribos

arribos=`find "$ARRDIR" -maxdepth 1 -type f -regex ${ARRDIR%/}"/.*" | wc -l`

if [[ $arribos -gt 0 ]]; then
	
	# Por cada uno de los archivos en el directorio de arribos
	for file in `find "$ARRDIR" -maxdepth 1 -type f -regex ${ARRDIR%/}"/.*"`
	do	
		validarFormato "$file"
		if [[ "$?" -eq 0  ]];then
			
			validarSIS_ID "$file"
			if [[ "$?" -eq 0  ]]; then

				validarFecha "$file"
				if [[ "$?" -eq 0  ]]; then
				# Archivo válido, pasa a carpeta de aceptados
				
					$BINDIR/MoverV5.sh "$file" "$ACEPDIR" "$pName"
					# Log de exito			
					$BINDIR/LoguearV5.sh -c "001" -f "$pName" -i "I"

				else
				# Fecha invalida
					$BINDIR/MoverV5.sh "$file" "$RECHDIR" "$pName"

					# Log de rechazo. Fecha incorrecta
					$BINDIR/LoguearV5.sh -c "002" -f "$pName" -i "E"
				fi
		
			else
			# SIS_ID invalido
				$BINDIR/MoverV5.sh "$file" "$RECHDIR" "$pName"

				# Log de rechazo. SIS_ID Inválido
				$BINDIR/LoguearV5.sh -c "003" -f "$pName" -i "E"
			fi
		else
		# Formato invalido
			$BINDIR/MoverV5.sh "$file" "$RECHDIR" "$pName"

			# Log de rechazo. Formato de archivo Inválido
			$BINDIR/LoguearV5.sh -c "004" -f "$pName" -i "E"
		fi
	done
fi


##
# Si hay archivos en el directorio de aceptado, se ejecuta el comando
# BuscarV5.sh para procesarlos.
##
aceptados=`find "$ACEPDIR" -maxdepth 1 -type f -regex ${ACEPDIR%/}"/.*" | wc -l`
 
if [[ $aceptados -gt 0 ]]; then
	
	pCallName="BuscarV5.sh"
	pID=`ps -C "$pCallName" -o "pid="`
	
	# Si BuscarV5 no se encuentra en ejecución
	if [[ $pID -eq 0 ]]; then
		$BINDIR/$pCallName
	else 
		echo ""$pCallName" ya se encuentra en ejecucion. Proceso ${pID/$'\n'}"
	fi
		
fi

##
# Tiempo de espera hasta el próximo ciclo, en segundos
##
sleep "$SLEEPTIME"

done

exit 0
