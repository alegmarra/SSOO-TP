#!/bin/bash

###############################################################################
# MoverV5  
# @brief   Mueve archivos de un directorio a otro, controlando posibles duplicados.
# @arg1    archivo:  origen
# @arg2    ruta:     destino
# @arg3    comando:  comando invocante
# @arg4    bool:     loguear resultados
###############################################################################


###############################################################################
# ayuda ()
# Muestra formato de uso del comando
###############################################################################

ayuda () {

	echo "MoverV5 -v 1.0 
  	      Mueve archivos de un directorio a otro, controlando posibles duplicados.
	      MoverV5.sh  <archivo origen> <ruta destino> <comando invocante> [OPCIONAL]
	      Opcion:
			-h : Ayuda
			-l : Loguear movimientos"
	
}


###############################################################################
# argumentosValidos ()
# @brief  Controla que las rutas de origen y destino, verificando existencia 
#	  y evitando movimientos sobre el mismo directorio 
# 
# @arg1   archivo a mover, con ruta de origen
# @arg2   ruta destino
###############################################################################

argumentosValidos () {
 
	# Normalizacion, elimina '/' final del nombre
	if [[ "$1" == */ ]]; then origenDir=${1%/}
	else origenDir=${1%/*}
	fi
	
	if [[ "$2" == */ ]]; then destinoDir=${2%/}
	else destinoDir=$2
	fi
	
	##
	# Validaciones
	##
	if [ "$origenDir" == "$destinoDir" ]; then 
		# Directorio destino igual al origen
		# Inválido
                if $loguear ; then

                        $BINDIR/LoguearV5.sh -c "605" -i "E" -f "MoverV5.sh" "$destino"
                fi

		return 1 
	else 
		if [ ! -e "$1" ]; then
			if [ ! -d "$origenDir" ]; then
				# No existe directorio de origen
		                if $loguear ; then
	
        		                $BINDIR/LoguearV5.sh -c "604" -i "I" -f "MoverV5.sh" \
							"$origen"
                		fi
				return 1
			fi
			
			# No existe archivo de origen
		        if $loguear ; then
	
        			$BINDIR/LoguearV5.sh -c "604" -i "I" -f "MoverV5.sh" \
							"$origen"
               		fi
			return 1
		fi	
	
		if [ ! -d "$destinoDir" ]; then
		        if $loguear ; then
	
        			$BINDIR/LoguearV5.sh -c "604" -i "I" -f "MoverV5.sh" \
							"$destino"
               		fi
			# No existe directorio de destino
			return 1
		fi
	fi
	
	# Argumentos válidos
	return 0
}

###############################################################################
# obtenerSecuenciador ()
#
# @brief  En caso de que el archivo origen ya exista en el directorio destino
#	  se busca el siguiente numero de copia correspondiente a dicho archivo
#	  en ese directorio particular.
#
# @arg1   Archivo origen
# @arg2   Ruta destino
#
# @return Siguiente numero de secuencia
###############################################################################

obtenerSecuenciador () {

	archivo=${1##*/}	
	archivo=${archivo%_${archivo#*_}}
	
	dirDestino=${2%/}/

	max=0
	
	##
	# Para cada archivo en el destino, que cumpla con el nombre de archivo 
	# de origen, se busca el máximo de los secuenciadores
	##
	for var in `find "$dirDestino" -maxdepth 1 -type f \
		    -regex "$dirDestino$archivo""_\([0-9]*\)_"`
	do
		# Separa unicamente el numero de secuencia
		var=${var#*_}
		var=${var%_*}
		
		if [[ "$var" -gt "$max" ]]; then
			max="$var"
		fi
	done
			
	siguiente=$[$max+1]
	
	return "$siguiente"
}



###############################################################################
# MAIN
###############################################################################
origen=
destino=
caller=
loguear=false


##
# Argumentos obligatorios
##
if [[ "$#" -lt 3 ]]; then
	echo "Cantidad de argumentos inválida"
	ayuda 

        $BINDIR/LoguearV5.sh -c "004" -i "SE" -f "MoverV5.sh" "3" "$#"

	exit 1
fi

##
# Argumento de log opcional
##
if [[ $4 == "-l" ]]; then

	loguear=true
fi

# Asignacion de rutas
origen="$1"
destino="$2"
caller="$3"


# Si las rutas son válidas
argumentosValidos "$origen" "$destino"
sonValidos="$?" 

if [[ "$sonValidos" -eq 0 ]]; then
	
	##
	# Intenta mover el archivo
	# -n impide el movimiento si existe el archivo en el destino
	## 
	mv -n "$origen" "$destino"

	if [ -e "$origen" ]; then
		
		# si no se pudo mover el archivo, busca el siguiente
		# numero de en la secuencia
		obtenerSecuenciador "$origen" "$destino"
		numCopia="$?"
		origenNext="$origen""_""$numCopia"_

		# renombra el archivo
		mv "$origen" "$origenNext"

		if $loguear ; then 

			$BINDIR/LoguearV5.sh -c "606" -i "I" -f "MoverV5.sh" "$origen" "$origenNext"
		fi

		# realiza el movimiento
		mv "$origenNext" "$destino"
	fi
	
	if [[ -e "$origen" || -e "$origenNext" ]]; then
		# no pudo mover el archivo, retorna con codigo de error
		if $loguear ; then 

			$BINDIR/LoguearV5.sh -c "603" -i "SE" -f "MoverV5.sh" "$origen"
		fi
		exit 1
	else
		if $loguear ; then 

			$BINDIR/LoguearV5.sh -c "602" -i "I" -f "MoverV5.sh" "$origen"
		fi
	fi	
else
	# Rutas de origen y/o destino inválidas
	if $loguear ; then 
		$BINDIR/LoguearV5.sh -c "005" -i "SE" -f "MoverV5.sh"
	fi
	exit 1
fi

exit 0
