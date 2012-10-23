#!/bin/bash


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
	
	"${BINDIR}"/"${pName}" "$@"

	if [ "$?" -eq 1 ]; then
		echo "El comando invocado terminó con error"
		exit 1	
	fi
}

iniciarBackground () {

	local pName="$1"
	shift 1
	
	"${BINDIR}"/"${pName}" "$@" &
	
	if [ `ps -C "$pName" -o "pid=" | wc -l` -lt 1 ]; then
		echo "Error: no pudo ejecutarse el comando" 
		exit 1
	fi	
}

iniciarDemonio () {
	local pName="$1"
	shift 1
	
	nohup "${BINDIR}"/"${pName}" "$@" 0<&- 1>/dev/null 2>&1 & 
	
	if [ `ps -C "$pName" -o "pid=" | wc -l` -lt 1 ]; then
		echo "Error: no pudo ejecutarse el comando" 
		exit 1
	fi	
}




##
# Validaciones
##

# Chequeo cantidad de argumentos correcta
if [[ "$#" -lt 2 ]]; then
	ayuda
	exit 1
fi

opcion="$1"
pName="$2"

# Chequeo si el proceso a llamar ya se encuentra en ejecución 
if [ `ps -C "$pName" | wc -l` -gt 1 ]; then
	exit 1
fi

# Chequeo que el directorio de binarios se encuentre en la variable BINDIR
if [ -z "${BINDIR}" ]; then
	echo "Error: entorno no inicializado.
	      Debe iniciarlizarse la variable BINDIR 
	      con la ruta al directorio de binarios"

	exit 1
fi

# Chequeo que exista el comando

if [ `find "${BINDIR}" -type f -name "${pName}" | wc -l` -lt 1 ]; then
	echo "Error: Comando especificado no encontrado"
	exit 1
fi

##
# Ejecucion según opciones
##
# Desplazo lista de argumentos, obtengo parametros del proceso en $@
shift 2

if [ ! -z "$opcion" ]; then 
	
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
