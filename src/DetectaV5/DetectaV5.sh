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

	echo "DAEMON=> nohup DetectaV5.sh 0<&- 1>/dev/null 2>&1 & "

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
# procesarArribos
# @brief Busca archivos nuevos en ARRDIR y los procesa
####################################################################
procesarArribos () {


	# Si hay archivos en la carpeta de arribos
	arribos=`find "$ARRDIR" -maxdepth 1 -type f -regex ${ARRDIR%/}"/.*" | wc -l`

	if [[ $arribos -gt 0 ]]; then
	
		# Log inicio procesado de archivos
		$BINDIR/LoguearV5.sh -c "302" -i "I" -f "$pName" "$arribos"
	

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
				
						$BINDIR/MoverV5.sh "$file" "$ACEPDIR" "$pName" "-l"
						# Log de exito			
						$BINDIR/LoguearV5.sh -c "302" -i "I" -f "$pName" "$file" 

					else
					# Fecha invalida
						$BINDIR/MoverV5.sh "$file" "$RECHDIR" "$pName" "-l"

						# Log de rechazo. Fecha incorrecta
						$BINDIR/LoguearV5.sh -c "305" -i "I" -f "$pName" "$file"
					fi
		
				else
				# SIS_ID invalido
					$BINDIR/MoverV5.sh "$file" "$RECHDIR" "$pName" "-l"

					# Log de rechazo. SIS_ID Inválido
					$BINDIR/LoguearV5.sh -c "304" -i "I" -f "$pName" "$file"
				fi
			else
			# Formato invalido
				$BINDIR/MoverV5.sh "$file" "$RECHDIR" "$pName" "-l"

				# Log de rechazo. Formato de archivo Inválido
				$BINDIR/LoguearV5.sh -c "303" -i "I" -f "$pName" "$file"
			fi
		done
	fi

}


####################################################################
# procesarAaceptados 
# @brief Busca archivos nuevos en ACEPDIR y ejecuta BuscarV5
####################################################################

procesarAceptados () {
	
	aceptados=`find "$ACEPDIR" -maxdepth 1 -type f -regex ${ACEPDIR%/}"/.*" | wc -l`
 
	if [[ $aceptados -gt 0 ]]; then
	
		pCallName="BuscarV5.sh"
		pID=`ps -C "$pCallName" -o "pid="`
	
	
		# Si BuscarV5 no se encuentra en ejecución
		if [[ $pID -eq 0 ]]; then
			$BINDIR/$pCallName &
	
			pID=`ps -C "$pCallName" -o "pid="`
			# Log llamado a BuscarV5	
			$BINDIR/LoguearV5.sh -c "006" -i "I" -f "$pName" "$pCallName" "$pID" 
		
		else 
		
			$BINDIR/LoguearV5.sh -c "007" -i "E" -f "$pName" "$pCallName" "${pID/$'\n'}"
		
			echo ""$pCallName" ya se encuentra en ejecucion. Proceso ${pID/$'\n'}"
		fi
		
	fi
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
export ARRDIR="./tests/arribos"
export MAEDIR="./tests/maestros"
export RECHDIR="./tests/rechazados"
export ACEPDIR="./tests/aceptados"
export BINDIR="./tests"
export SLEEPTIME="2" #segundos
export pName="DetectaV5.sh"

##


# Log inicio Demonio
$BINDIR/LoguearV5.sh -c "301" -i "I" -f "$pName"


# Verificar si la inicializacion de ambiente
# se realizo anteriormente:
##
$BINDIR/IniciarV5.sh "-inicializado" > /dev/null
INICIALIZADO=$? # atrapo el codigo de retorno de IniciarV5
if [ $INICIALIZADO -eq 0 ]; then
        
	
	$BINDIR/LoguearV5.sh -c "001" -i "SE" -f "$pName"

	echo "El sistema no fue inicializado.
	      Debe inicializarlo antes con el comando $BINDIR/IniciarV5."
        exit 1
fi

##
# Chequeo de ejecución única del proceso. 
##

if [[ `ps -C "$pName" -o "pid=" | wc -l` -gt 2 ]]; then

	prevID=` ps -C "$pName" -o "pid=" ` 
	prevID=${prevID%[^0-9]*}
	
	$BINDIR/LoguearV5.sh -c "007" -i "SE" -f "$pName" "$pName" "$prevID"
	
	echo "DetectaV5 ya se encuentra en ejecucion. Proceso $prevID "

	exit 1

fi


##
# Inicio Loop Demonizado
##
while true; do

	# Verifica existencia de ARRDIR
	if [ -d "$ARRDIR" ]; then

		procesarArribos	

	else
		# Log Maestro no encontrado 
		$BINDIR/LoguearV5.sh -c "003" -i "E" -f "$pName" "$ARRDIR"
	fi
	
	# Verifica existencia de ACEPDIR
	if [ -d "$ACEPDIR" ]; then
	
		procesarAceptados
	else
	
		# Log Maestro no encontrado 
		$BINDIR/LoguearV5.sh -c "003" -i "E" -f "$pName" "$ACEPDIR"

	fi

	##
	# Tiempo de espera hasta el próximo ciclo, en segundos
	##
	sleep "$SLEEPTIME"

done

exit 0
