#!/bin/sh

PROCDIR=./Procesados
MAEDIR=./ArchivosMaestros
export PROCDIR
export MAEDIR

./ListarV5.pl $@

COD_RES=$?

echo "\n-----------------------------------------"
echo "Codigo devuelto por ListarV5.pl: $COD_RES"
