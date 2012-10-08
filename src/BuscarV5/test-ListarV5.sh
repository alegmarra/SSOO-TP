#!/bin/sh

PROCDIR=./Procesados
export PROCDIR

./ListarV5.pl $@

COD_RES=$?

echo "\n-----------------------------------------"
echo "Codigo devuelto por ListarV5.pl: $COD_RES"
