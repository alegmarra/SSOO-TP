#!/bin/sh

#~ IniciarV5 de juguete, que devuelve 1 cuando se le pregunta
#~ si esta inicializado, porque el modulo buscar lo consulta.

for i in $*; do
	if [ $i=="-inicializado" ]; then
		return 1
	fi
done
