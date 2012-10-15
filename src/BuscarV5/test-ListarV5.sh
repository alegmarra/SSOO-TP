#!/bin/sh

PROCDIR=./Procesados
MAEDIR=./ArchivosMaestros
REPODIR=./Reportes
export PROCDIR
export MAEDIR
export REPODIR

./ListarV5.pl $@

COD_RES=$?

echo "\n-----------------------------------------"
echo "Codigo devuelto por ListarV5.pl: $COD_RES"
