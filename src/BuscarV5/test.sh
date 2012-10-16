#!/bin/sh

BINDIR=./Ejecutables
ACEPDIR=./Aceptados
CONFDIR=./Configuraciones
PROCDIR=./Procesados
MAEDIR=./ArchivosMaestros
RECHDIR=./Rechazados

# Mover todos los archivos de la carpeta de procesados al comienzo
#~ mv ./Procesados/*_* ./Aceptados/ > /dev/null
#~ mv ./Rechazados/*_* ./Aceptados/ > /dev/null
#~ rm ./Procesados/*

export BINDIR
export ACEPDIR
export CONFDIR
export PROCDIR
export MAEDIR
export RECHDIR

./BuscarV5.sh

COD_RES=$?

echo "Codigo devuelto por BuscarV5.sh: $COD_RES"

if [ -e $PROCDIR/resultados.8 ]; then
	echo "OK"
else
	echo "ERROR"
fi

if [ -e $PROCDIR/resultados.9 ]; then
	echo "OK"
else
	echo "ERROR"
fi

if [ -e $PROCDIR/rglobales.8 ]; then
	echo "OK"
else
	echo "ERROR"
fi

if [ -e $PROCDIR/rglobales.9 ]; then
	echo "OK"
else
	echo "ERROR"
fi

read -r linea < ./Procesados/rglobales.8
if echo "$linea" | grep -E "*,1,5,1" > /dev/null
then
	echo "OK"
else
	echo "ERROR"
fi

read -r linea < ./Procesados/rglobales.9
if echo "$linea" | grep -E "*,2,3,1" > /dev/null
then
	echo "OK"
else
	echo "ERROR"
fi

read -r linea < ./Procesados/resultados.8
if echo "$linea" | grep -E "*cielo$" > /dev/null
then
	echo "OK"
else
	echo "ERROR"
fi

read -r linea < ./Procesados/resultados.9
if echo "$linea" | grep -E "*rojo$" > /dev/null
then
	echo "OK"
else
	echo "ERROR"
fi
