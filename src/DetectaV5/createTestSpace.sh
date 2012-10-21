#!/bin/bash


# CREAR directorio base

if [ ! -d "./tests" ]; then
	mkdir "tests"
fi

BINDIR="./tests"

# LIMPIAR: .sh .results aceptados/* rechazados/* maestros/* arribos/* 

rm ${BINDIR}/*    # .sh y ListaErrores
rm ${BINDIR}/*/*  # arribos, maestros, aceptados, rechazados
# COPIAR: binarios, maestros, ListaErrores

for script in `find "../" -maxdepth 2 -type f -regex "../"[A-Za-z0-9]*"/"[A-Za-z0-9]+"V5.sh"`
do
	cp -n ${script} "${BINDIR}/"
	chmod +x "${BINDIR}/${script##*/}"
done

# CREAR: arribos, dummys: Iniciar y Buscar 

if [ ! -d "${BINDIR}/arribos" ]; then mkdir "${BINDIR}/arribos"; fi
if [ ! -d "${BINDIR}/rechazados" ]; then mkdir "${BINDIR}/rechazados"; fi
if [ ! -d "${BINDIR}/maestros" ]; then mkdir "${BINDIR}/maestros"; fi
if [ ! -d "${BINDIR}/aceptados" ]; then mkdir "${BINDIR}/aceptados"; fi
# CORRER: Detecta

# ANALIZAR: resultados

# PRESENTAR: resultados
