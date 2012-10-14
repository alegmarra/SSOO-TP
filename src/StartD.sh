#!/bin/bash

BINDIR="./testBin"

# Dispara el proceso @arg1 con las condiciones indicadas en @arg2

ayuda () {

	echo "StarD.sh <NombreProceso.sh> [OPCION...] <Argumentos>
	      Opciones:
			-h : Muestra esta ayuda
			-A : El proceso utiliza argumentos. 
			     Si se utiliza debe ser la primer opcion.
			
			-D : Inicia el proceso demonizado
			-B : Inicia el proceso en segundo plano" 
}

iniciarDemonio () {
	`nohup $BINDIR/$1 0<&- 1>/dev/null 2>&1 & `
}

iniciarBackground () {
	`$BINDIR/$1 &`
}

iniciarConArgumentos () {

	echo "TODO"
# @TODO (me tengo que ir, despues lo termino)

}

if [[ "$#" -lt 1 ]]; then
	ayuda
	exit 1
fi

pName="$1"


if [[ ! -z "$2" ]]; then 
	
	case "$2" in
		-h) ayuda; exit 1
		;;
		-A) iniciarConArgumentos "$@" 
		;;
		-D) iniciarDemonio "$pName"
		;;
		-B) iniciarBackground "$pName"
		;;
	esac 	
else

 	`$BINDIR/$pName`
fi

exit 0
	

