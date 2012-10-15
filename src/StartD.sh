#!/bin/bash

BINDIR="./testBin"

# Dispara el proceso @arg1 con las condiciones indicadas en @arg2

ayuda () {

	echo "StarD.sh [OPCION] <NombreProceso.sh> <Argumentos>
	      Opciones:
			-h : Muestra esta ayuda
			-F : Inicia el proceso en primer plano
			-B : Inicia el proceso en segundo plano
			-D : Inicia el proceso demonizado"
}



iniciarForeground () {

	local pName="$1"
	shift 1
	
	"$BINDIR"/"$pName" "$@"
}

iniciarBackground () {

	local pName="$1"
	shift 1
	
	"$BINDIR"/"$pName" "$@" &
}

iniciarDemonio () {
	local pName="$1"
	shift 1
	
	nohup "$BINDIR"/"$pName" "$@" 0<&- 1>/dev/null 2>&1 & 
}



if [[ "$#" -lt 2 ]]; then
	ayuda
	exit 1
fi

opcion="$1"
pName="$2"

# Desplazo lista de argumentos, obtengo parametros del proceso
shift 2

if [[ `ps -C "$pName" | wc -l` -gt 1 ]]; then
	exit 1
fi


if [[ ! -z "$opcion" ]]; then 
	
	case "$opcion" in
		-h) ayuda; exit 1
		;;
		-F) iniciarForeground "$pName" "$@"
		;;
		-B) iniciarBackground "$pName" "$@"
		;;
		-D) iniciarDemonio "$pName" "$@"
		;;
		*) ayuda; exit 1
		;;
	esac 	
else
	ayuda
	exit 1
fi

exit 0
