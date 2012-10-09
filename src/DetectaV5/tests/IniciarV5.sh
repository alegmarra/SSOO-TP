#!/bin/sh

#~ IniciarV5 de juguete, que devuelve 0 cuando se le pregunta
#~ si esta inicializado, porque el modulo buscar lo consulta.

for i in $*; do
	if [ $i=="-inicializado" ]; then
		exit 0
	fi
done

exit 1
