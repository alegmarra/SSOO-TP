#!/bin/bash

# MoverV5 -v 1.0 
# Mueve archivos de un directorio a otro, controlando posibles duplicados.
# @arg1    ruta origen
# @arg2    ruta destino
# @arg3    codigo comando invocante
# @arg4..n opcionales segun invocante


# Validación de directorios
# Si el origen o el destino pasados no existen se retorna con error

directorioValido () {
 
	if [ ! -d "$1" ]; then
		echo "Directorio inexistente '$1'"
		#@TODO log del error
		return 1
	fi
	return 0
}

#MAIN

if [ $# -lt 3 ]; then
	echo "Faltan parámetros"
	# @TODO Logeo de error?
	exit 1
fi

origen=$1
destino=$2

if directorioValido $origen && directorioValido $destino; then


else
	echo "NOT OK"
fi	
