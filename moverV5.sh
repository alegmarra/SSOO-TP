#!/bin/bash

# MoverV5 -v 1.0 
# Mueve archivos de un directorio a otro, controlando posibles duplicados.
# @arg1    ruta origen
# @arg2    ruta destino
# @arg3    codigo comando invocante
# @arg4..n opcionales segun invocante


# Validación de directorios
argumentosValidos () {
 
	if [ $1 == $2 ]; then 
		return 1
	else 
		if [ ! -e $1 ]; then
			if [ ! -d $1 ]; then
				return 1
			fi
		fi	
	
		if [ ! -d $2 ]; then
			return 1 
		fi
	fi

	return 0
}


obtenerSecuenciador () {

	return 4

}

#MAIN


if [ $# -lt 2 ]; then
	echo "Faltan parámetros"
	# @TODO Logeo de error?
	exit 1
fi

origen=$1
destino=$2

if argumentosValidos $origen $destino; then
	
	mv -n $origen $destino

	if [ -e $origen ]; then
		
		obtenerSecuenciador $destino
		numCopia=$?
		origenNext=$origen""$numCopia

		mv $origen $origenNext
				
		mv $origenNext $destino
	fi

	if [[ -e $origen || -e $origenNext ]]; then
		exit 1
	fi	
fi

