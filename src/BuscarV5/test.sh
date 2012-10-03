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

./BuscarV5.sh

COD_RES=$?

echo "-----------------------------------------"
echo "Codigo devuelto por BuscarV5.sh: $COD_RES"
