#!/bin/bash

CONFIG_FILE="./conf/InstalaV5.conf"
VARIABLES=(GRUPO CONFDIR BINDIR MAEDIR ARRIDIR ACEPDIR RECHDIR PROCDIR REPODIR LOGDIR LOGEXT LOGSIZE)
COMANDOS=(DetectaV5 BuscarV5 ListarV5 MoverV5 LoguearV5 MirarV5 StopD StartD)
ARCHIVOS_MAE=(patrones sistemas)
# Variables para informar al usuario
HEADER="TP SO7508 Segundo Cuatrimestre 2012. Tema V Copyright © Grupo 07"
DESCRIPCIONES=()
DESCRIPCIONES[0]="$HEADER"
DESCRIPCIONES[1]="Librería del Sistema: "
DESCRIPCIONES[2]="Ejecutables: "
DESCRIPCIONES[3]="Archivos maestros: "
DESCRIPCIONES[4]="Directorio de arribo de archivos externos: "
DESCRIPCIONES[5]="Archivos externos aceptados: "
DESCRIPCIONES[6]="Archivos externos rechazados: "
DESCRIPCIONES[7]="Archivos procesados: "
DESCRIPCIONES[8]="Reportes de salida: "
DESCRIPCIONES[9]="Logs de auditoría del sistema: "
###

mostrarDescripcionYListarArchivos () {
	echo "${DESCRIPCIONES[$1]}" "${!VARIABLES[${i}]}"
	ls -l "${!VARIABLES[${1}]}" | awk '{ print $8 }' | grep --color=never '..*' # grep para evitar líneas vacías
}

# Verifica que un proceso de nombre $1 esté corriendo, y guarda en $2 el PID
# $1 nombre de proceso
# $2 variable para almacenar el PID
verificarProceso () {
	if [ `ps -C "$1" -o "pid=" | wc -l` -gt 2 ]
	then
		local prevID=` ps -C "$1" -o "pid=" `
		$2=${prevID/[^0-9]*$$}
	fi
}

mostrarVariables () {
	echo "$HEADER"

	for i in {1..3}
	do
		mostrarDescripcionYListarArchivos "${i}"
	done

	for ((i = 4; i < "${#VARIABLES[@]}" - 2; ++i))
	do
		echo "${DESCRIPCIONES[$i]}" "${!VARIABLES[$i]}"
	done

	echo "${DESCRIPCIONES[9]}" "$LOGDIR/<comando>.$LOGEXT"
}

# Verifica si todas las variables de ambiente están seteadas.
# Retorna 1 en el caso positivo, 0 de otra manera
verificarSiYaSeIniciaronLasVariables () {
	local CANT_INICIALIZADAS=0
		
	for i in "${VARIABLES[@]}"
	do
		if [ "${!i}" ]
		then
			((++CANT_INICIALIZADAS))
		fi
	done
	
	if [ `expr ${#VARIABLES[@]} - ${CANT_INICIALIZADAS}` -eq 0 ] 
	then
		return 1
	fi
	return 0
}

verificarSiYaSeSeteoPath () {
	echo "$PATH" | grep "$BINDIR" > /dev/null
	if [ $? -eq 0 ]
	then
		return 1
	fi
	return 0
}

verificarSiYaEstaCorriendoElDemonio () {
	INI=
	verificarProceso "DetectaV5.sh" $INI
	if [ ! -z "${INI}" ]
	then
		return 1
	fi
	return 0
}

# Llama a las tres funciones de verificación de entorno y retorna 1 si
# las tres retornan 1, 0 de otra forma
verificarSiYaSeInicioElEntorno () {
	verificarSiYaSeIniciaronLasVariables
	if [ $? -eq 0 ]
	then
		exit 0
	fi

	verificarSiYaSeSeteoPath
	if [ $? -eq 0 ]
	then
		exit 0
	fi

	exit 1
}

init () {
	if [ $# -gt 0 ] && [ "$1" = "-inicializado" ]
	then
		verificarSiYaSeInicioElEntorno
	fi
}

setearVariablesDeEntorno () {
	for i in "${VARIABLES[@]}"
	do
		TEMP=`grep "^${i}" "${CONFIG_FILE}" | awk 'BEGIN { FS="="; } { print $2 }'`
		if [ $? -eq 1 ]
		then
			echo "Archivo de configuración corrupto: variable ${i} no encontrada"
			return $?
		elif [ $? -eq 2 ]
		then
			echo "Archivo de configuración no encontrado"
			return $?
		fi
		export `echo ${i}`="${TEMP}"
	done
}

verificarSiLaInstalacionEstaCompleta () {
	local FALTANTES=()
	local i=0
	
	for CMD in "${COMANDOS[@]}"
	do
		ls "${BINDIR}" | grep "${CMD}" > /dev/null
		if [ $? -eq 1 ]
		then
			FALTANTES[((i++))]="${CMD}"
		fi
	done

	for ARCH in "${ARCHIVOS_MAE[@]}"
	do
		ls "${MAEDIR}" | grep "${ARCH}" > /dev/null
		if [ $? -eq 1 ]
		then
			FALTANTES[((i++))]="${ARCH}"
		fi
	done

	if [ "${#FALTANTES[@]}" -gt 0 ]
	then
		echo "$HEADER"
		echo "Componentes Existentes:"
		mostrarDescripcionYListarArchivos 2
		mostrarDescripcionYListarArchivos 3
		echo "Componentes faltantes:"
		for i in "${FALTANTES[@]}"
		do
			echo "${i}"
		done
		echo "Estado de la instalación: INCOMPLETA"
		echo "Proceso de Inicialización Cancelado"
		return 1
	fi
}

invocarDetecta () {
	"${BINDIR}"/StartD.sh -D DetectaV5.sh
	if [ $? -eq 0 ]
	then
		PID=0
		verificarProceso "DetectaV5.sh" "${PID}"
		"${BINDIR}"/LoguearV5.sh -c 102 -f IniciarV5 -i A "${PID}"
	fi
}

fin () {
	"${BINDIR}"/LoguearV5.sh -c 103 -f IniciarV5 -i I
}


iniciarSiLaInstalacionEstaCompleta () {
	verificarSiLaInstalacionEstaCompleta

	if [ $? -ne 1 ]
	then
		mostrarVariables

		invocarDetecta

		fin
	else
		if [ ! -z "${BINDIR}" ]
		then
       			PATH=`echo "${PATH}" | sed "s_\:${BINDIR}__g"`
		fi

		for i in "${VARIABLES[@]}"
		do      
		        unset `echo ${i}`
		done
	fi
}

### MAIN ###

init $1

verificarSiYaSeIniciaronLasVariables
if [ $? -eq 0 ]
then
	setearVariablesDeEntorno
	if [ $? -ne 0 ]
	then
		echo "Proceso de Inicialización Cancelado"
	else
		"${BINDIR}"/LoguearV5.sh -c 101 -f IniciarV5 -i I
		
		verificarSiYaSeSeteoPath
		if [ $? -eq 0 ]
		then
			export PATH="${PATH}:${BINDIR}"
		fi

		iniciarSiLaInstalacionEstaCompleta
	fi
else
	echo "Previo al log"
	"${BINDIR}"/LoguearV5.sh -c 101 -f IniciarV5 -i I
	echo "Después del log"
	verificarSiYaSeSeteoPath
	if [ $? -eq 0 ]
	then
		export PATH="${PATH}:${BINDIR}"

		iniciarSiLaInstalacionEstaCompleta
	else
		verificarSiYaEstaCorriendoElDemonio

		if [ $? -eq 0 ]
		then
			iniciarSiLaInstalacionEstaCompleta
		else
			mostrarVariables
			echo "Estado del Sistema: INICIALIZADO"
			echo "No es posible efectuar una reinicialización del sistema"
			echo "Proceso de Inicialización Cancelado"
		fi
	fi
fi

