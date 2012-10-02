#!/bin/sh

BINDIR=./Ejecutables
ACEPDIR=./Aceptados
CONFDIR=./Configuraciones
PROCDIR=./Procesados
MAEDIR=./ArchivosMaestros
RECHDIR=./Rechazados

# Mover todos los archivos de la carpeta de procesados al comienzo
mv ./Procesados/*_* ./Aceptados/ > /dev/null
mv ./Rechazados/*_* ./Aceptados/ > /dev/null

export BINDIR
export ACEPDIR
export CONFDIR
export PROCDIR
export MAEDIR
export RECHDIR

if [ $# -gt 0 ]; then
	if [ $1 = "-nd" ]; then
		cat BuscarV5.sh | grep -v -e "DEBUG:"  > aux_test.sh
		chmod a+x aux_test.sh
		./aux_test.sh
	fi
else
	./BuscarV5.sh
fi

COD_RES=$?

echo "-----------------------------------------"
echo "Codigo devuelto por BuscarV5.sh: $COD_RES"
