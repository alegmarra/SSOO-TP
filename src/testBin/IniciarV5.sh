#!/bin/bash 

#esta es la posta: 
CONFIG_FILE="../conf/InstalaV5.conf"
#test: 
CONFIG_FILE="InstalaV5.conf"
VARIABLES=(GRUPO CONFDIR BINDIR MAEDIR ARRIDIR ACEPDIR RECHDIR PROCDIR REPODIR LOGDIR LOGEXT)
COMANDOS=(IniciarV5 DetectaV5 BuscarV5 ListarV5 MoverV5 LoguearV5 MirarV5 StopD StartD)
ARCHIVOS_MAE=(patrones sistemas)
# Variables para informar al usuario
HEADER="TP SO7508 Segundo Cuatrimestre 2012. Tema V Copyright © Grupo 07"
declare -A DESCRIPCIONES
DESCRIPCIONES[CONFDIR]="Librería del Sistema: "
DESCRIPCIONES[BINDIR]="Ejecutables: "
DESCRIPCIONES[MAEDIR]="Archivos maestros: "
DESCRIPCIONES[ARRIDIR]="Directorio de arribo de archivos externos: "
DESCRIPCIONES[ACEPDIR]="Archivos externos aceptados: "
DESCRIPCIONES[RECHDIR]="Archivos externos rechazados: "
DESCRIPCIONES[PROCDIR]="Archivos procesados: "
DESCRIPCIONES[REPODIR]="Reportes de salida: "
DESCRIPCIONES[LOGDIR]="Logs de auditoría del sistema: "

mostrarDescripcionYListarArchivos () {
	echo ${DESCRIPCIONES[$1]} ${!1}
	cd ${!1}
	ls -l | awk '{ print $9 }' | grep --color=never '..*' # grep para evitar líneas vacías		
	cd ~-
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

mostrarVariables () {
	echo $HEADER

	for i in {1..3}
	do
		mostrarDescripcionYListarArchivos ${VARIABLES[$i]}
	done

	for ((i = 4; i < ${#VARIABLES[@]} - 2; ++i))
	do
		TEMP=${VARIABLES[$i]}	
    	echo ${DESCRIPCIONES[$TEMP]} ${!TEMP}
	done

	echo ${DESCRIPCIONES[LOGDIR]} "$LOGDIR/<comando>.$LOGEXT"
}

# Verifica si todas las variables de ambiente están seteadas. 
# Si recibe un parámetro, está siendo consultado desde afuera. 
# Entonces, al detectar que todas las variables están inicializadas, y no
# está siendo consultado, informa los valores de esas variables. Si lo están
# consultando, no informa nada. De todas formas, sale con exit 0
verificarSiYaSeInicioElEntorno () {
	local CANT_INICIALIZADAS=0
	for i in "${VARIABLES[@]}"
	do
		if [ ${!i} ]
		then
			((++CANT_INICIALIZADAS))
		fi
	done
	if [ -z `expr ${#VARIABLES[@]} - ${CANT_INICIALIZADAS}` ]
	then
		if [ -z $# ]
		then
			mostrarVariables 
			echo "Estado del Sistema: INICIALIZADO"
			echo "No es posible efectuar una reinicialización del sistema"
			echo "Proceso de Inicialización Cancelado"			
		fi
		exit 0
	fi
}

init () {
	if [ $# -gt 0 ] && [ $1 == "-inicializado" ]
	then
		verificarSiYaSeInicioElEntorno $1
	fi	

	echo "Comando IniciarV5 Inicio de Ejecución @todo: log"
}

setearVariablesDeEntorno () {
	for i in "${VARIABLES[@]}"
	do	
		TEMP=`grep "^${i}" ${CONFIG_FILE} | awk 'BEGIN { FS="="; } { print $2 }'`
		export `echo ${i}`=${TEMP}
	done
}

verificarSiLaInstalacionEstaCompleta () {
	local FALTANTES=()
	local i=0
	cd ${BINDIR}
	for CMD in ${COMANDOS[@]}
	do
		ls | grep ${CMD} > /dev/null
		if [ $? -eq 1 ]
		then
			FALTANTES[((i++))]=${CMD}
		fi
	done

	cd ${MAEDIR}
	for ARCH in ${ARCHIVOS_MAE[@]}
	do
		ls | grep ${ARCH} > /dev/null
		if [ $? -eq 1 ]
		then
			FALTANTES[((i++))]=${ARCH}
		fi
	done

	if [ ${#FALTANTES[@]} -gt 0 ]
	then
		echo $HEADER
		echo "Componentes Existentes:"
		mostrarDescripcionYListarArchivos ${BINDIR}
		mostrarDescripcionYListarArchivos ${MAEDIR}
		echo "Componentes faltantes:"
		for i in ${FALTANTES[@]}
		do
			echo ${FALTANTES[$i]}
		done
		echo "Estado de la instalación: INCOMPLETA"
		echo "Proceso de Inicialización Cancelado"
		exit 1
	fi
}

invocarDetecta () {
	${BINDIR}/StartD.sh DetectaV5.sh -D
	if [ -z $? ]
	then
		PID=0
		verificarProceso "DetectaV5.sh" ${PID}
		echo "Demonio corriendo bajo el Nro: ${PID}"
	fi
}

fin () {
	echo "Proceso de Inicialización Concluido @todo: loguear y cerrar"
}

### MAIN ###

init $1

verificarSiYaSeInicioElEntorno

setearVariablesDeEntorno

export PATH=${PATH}:`pwd`; echo "@todo: revisar si está bien la variable PATH"

verificarSiLaInstalacionEstaCompleta

mostrarVariables

invocarDetecta

fin

