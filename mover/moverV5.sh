#!/bin/bash

# MoverV5 -v 1.0 
# Mueve archivos de un directorio a otro, controlando posibles duplicados.
# @arg1    ruta origen
# @arg2    ruta destino
# @arg3    codigo comando invocante - Obligatorio si precisan logueo


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

	if [ ! -z "$3" ]; then 
		# @TODO Logeo de error
		echo "FALTAN PARAMETROS" >> mover.log
	fi
	exit 1
fi

origen=$1
destino=$2

if argumentosValidos $origen $destino; then
	
	# -n impide el movimiento si existe el archivo en el destino
	mv -n $origen $destino

	if [ -e $origen ]; then
		
		# si no se pudo mover el archivo, busca el siguiente
		# numero de en la secuencia
		obtenerSecuenciador $destino
		numCopia=$?
		origenNext=$origen""$numCopia

		# renombra el archivo
		mv $origen $origenNext
		# realiza el movimiento
		mv $origenNext $destino
	fi
	
	if [[ -e $origen || -e $origenNext ]]; then
		# no pudo mover el archivo, retorna con codigo de error
		if [ ! -z "$3" ]; then 
			# @TODO log de error

			echo "NO PUDO MOVER" >> mover.log
		fi
		exit 1
	fi	
else
	if [ ! -z "$3" ]; then 
		# @TODO log de error
			echo "ARG invalidos" >> mover.log
	fi
	exit 1
fi
