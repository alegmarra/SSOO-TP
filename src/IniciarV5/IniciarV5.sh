#!/bin/bash 

THIS=${0##*/} # Removiendo el "./" del principio
#@todo esta es la posta CONFIG_FILE="../conf/InstalaV5.conf"
CONFIG_FILE="InstalaV5.conf"
VARIABLES=(GRUPO CONFDIR BINDIR MAEDIR ARRIDIR ACEPDIR RECHDIR PROCDIR REPODIR LOGDIR)


# Verifica si todas las variables de ambiente están seteadas y retorna la cantidad de indefinidas.
# Si algunas estuvieran inicializadas pero otras no, entonces por algún error deben ser todas
# inicializadas de nuevo, entonces un valor de retorno 0 sería que el ambiente está listo.
verificarSiYaSeInicioElEntorno () {
	local CANT_INICIALIZADAS=0
	for i in "${VARIABLES[@]}"
	do
		if [ ${!i} ]
		then
			((++CANT_INICIALIZADAS))
		fi
	done
	return `expr ${#VARIABLES[@]} - ${CANT_INICIALIZADAS}` 
}

mostrarVariables () {
	echo "@todo: Loguear cada variable y listar los archivos en los dir"
}
 
# Verifica que un proceso de nombre $1 esté corriendo, y guarda en $2 el PID
# $1 nombre de proceso
# $2 variable para almacenar el PID
verificarProceso () {

	if [[ `ps -C "$1" -o "pid=" | wc -l` -gt 2 ]]; then

		local prevID=` ps -C "$1" -o "pid=" ` 
		$2=${prevID/[^0-9]*$$}

	fi
}
echo "Comando ${THIS%.*} Inicio de Ejecucion @todo: log"

verificarSiYaSeInicioElEntorno

if [ -z $? ]
then
	echo "Ya está corriendo @todo: mostrar mensaje del enunciado"
	exit 1
fi

export PATH=${PATH}:`pwd`

echo "@todo: revisar si está bien la variable PATH, y si debe ser exportada"

echo "Asumiendo que la instalación está completa @todo: verificar si la instalación está completa"

for i in "${VARIABLES[@]}"
do
	TEMP=`grep "^${i}" ${CONFIG_FILE} | awk 'BEGIN { FS="="; } { print $2 }'`
	export `echo ${i}`=${TEMP}
done

mostrarVariables
./DetectaV5.sh
if [ -z $? ]
then
	PID=0
	verificarProceso "DetectaV5.sh" ${PID}
	echo "Demonio corriendo bajo el Nro: ${PID}"
fi
echo "Proceso de Inicialización Concluido @todo: loguear y cerrar"

