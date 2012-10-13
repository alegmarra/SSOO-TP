#!/bin/bash

# Dispara el proceso @arg1 con las condiciones indicadas en @arg2

ayuda () {

	echo "StarD.sh <NombreProceso.sh> [OPCION...] <Argumentos>
	      Opciones:
			-h : Muestra esta ayuda
			-A : El proceso utiliza argumentos
			-D : Inicia el proceso demonizado
			-B : Inicia el proceso en segundo plano" 
}

iniciarDemonio () {
	`nohup "$1" 0<&- 1>/dev/null 2>&1 & `
}

iniciarBackground () {
	`"$1" &`
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

 	`$pName`
fi

exit 0
	

