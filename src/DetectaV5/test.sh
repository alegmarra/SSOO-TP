#!/bin/bash

limpiar () {

tests/reset.sh

rm tests/arribos/*
rm tests/maestros/sistemas

}

crearSistemas () {

echo "sasapp;unix;2012-09-30;2012-10-01" >> ./tests/maestros/sistemas
echo "sa2sapp;unix;1990-02-28;2012-01-01" >> ./tests/maestros/sistemas 
echo "soapp1;unix;2002-01-01;" >> ./tests/maestros/sistemas
echo "testapp;bla;2012-01-01;2013-01-01" >> ./tests/maestros/sistemas
 
}

crearArribos () {

arribos=./tests/arribos

echo "Formato Invalido: No tiene Fecha " > $arribos/pepe

echo "Formato Invalido: No respeta fechas " > $arribos/pepe_2004-10-10_1

echo "SIS_ID Invalido " > $arribos/pepe_2004-10-10

echo "Fecha Invalida: Pre ALTA" > $arribos/sa2sapp_1900-09-30

echo "Valido" > $arribos/sa2sapp_1990-05-10

echo "Fecha Invalida: Post BAJA" > $arribos/sa2sapp_2012-09-30

echo "Valido" > $arribos/sasapp_2012-09-30

echo "Fecha Invalida: Post BAJA" > $arribos/sasapp_2012-10-10

echo "Fecha Invalida: Previo ALTA" > $arribos/soapp1_2000-10-10

echo "Valido" > $arribos/soapp1_2004-10-10

echo "Fecha Invalida: Mayor que hoy" > $arribos/testapp_2013-01-01
}




verificar () {
echo TODO

}


limpiar

crearSistemas

crearArribos

./DetectaV5.sh 



