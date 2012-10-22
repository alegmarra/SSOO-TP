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
	if [ "$1" = */ ]; then origenDir=${1%/}
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

                        LoguearV5.sh -c "605" -i "E" -f "MoverV5.sh" "$destino"
                fi

		return 1 
	else 
		if [ ! -e "$1" ]; then
			if [ ! -d "$origenDir" ]; then
				# No existe directorio de origen
		                if $loguear ; then
	
        		                LoguearV5.sh -c "604" -i "I" -f "MoverV5.sh" "$origen"
                		fi
				return 1
			fi
			
			# No existe archivo de origen
		        if $loguear ; then
	
        			LoguearV5.sh -c "604" -i "I" -f "MoverV5.sh" "$1"
               		fi
			return 1
		fi	
	
		if [ ! -d "$destinoDir" ]; then
		        if $loguear ; then
	
        			LoguearV5.sh -c "604" -i "I" -f "MoverV5.sh" "$destino"
               		fi
			# No existe directorio de destino
			return 1
		fi
	fi
	
	# Argumentos válidos
	return 0
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
if [ "$#" -lt 3 ]; then
	echo "Cantidad de argumentos inválida"
	ayuda 

       	LoguearV5.sh -c "004" -i "SE" -f "MoverV5.sh" "3" "$#"

	exit 1
fi

##
# Argumento de log opcional
##

case $4 in
	-l) loguear=true;
	;;
	-h) ayuda ; exit 1;
	;;
esac

# Asignacion de rutas
origen="$1"
destino="$2"
caller="$3"


# Si las rutas son válidas
argumentosValidos "$origen" "$destino"
sonValidos="$?" 

if [ "$sonValidos" -eq 0 ]; then
	
	##
	# Opciones de mv utilizadas:
	#
	# --backup: make a backup of each existing destination file
	# =t	  : make numbered backups 
	# sufijo  : por defecto, ~
	## 
	mv --backup=t "$origen" "$destino"
	
	if $loguear ; then 
		LoguearV5.sh -c "602" -i "I" -f "MoverV5.sh" "$origen"
	fi	
else
	# Rutas de origen y/o destino inválidas
	if $loguear ; then 
		LoguearV5.sh -c "005" -i "SE" -f "MoverV5.sh"
	fi
	exit 1
fi

exit 0
