#!/bin/bash


# Test suite para moverV5.sh

resultado (){

	destino="./tests/""$2"".result"

	if [ !"$1" ]; then
		echo "TEST OK" >> "$destino"
	else
		echo "TEST FAILED" >> "$destino"
	fi

}

limpiar () {
	
	rm -f *.test
	rm -f ./tests/*.test
}

# Test mover archivo valido a directorio valido, sin duplicado

test_moverArchivo_OrigenDestinoValidos () {
	
	falla=false

	# Creacion
	echo "test_1" > 1.test
	
	./moverV5.sh 1.test tests "pcional"
	
	# Prueba
	if [ -e 1.test ]; then
		echo "Falla: No movido de origen" >> ./tests/1.result
		falla=true
	fi
	
	if [ ! -e ./tests/1.test ]; then
		echo "Falla: No movido a destino" >> ./tests/1.result
		falla=true
	fi
	
	resultado "$falla" 1

	limpiar 
	
}



# Test mover archivo valido a directorio invalido, sin duplicado

test_moverArchivo_OrigenValido_DestinoInvalido () {

	falla=false
	
	# Creacion
	echo "test_2" > 2.test
	
	./moverV5.sh 2.test inexistente
	
	# Prueba
	if [ ! -e 2.test ]; then
		echo "Falla: Movido de origen" >> ./tests/2.result
		falla=true
	fi
	
	resultado "$falla" 2
	limpiar 
	
}

# Test mover archivo invalido a directorio valido, sin duplicado

test_moverArchivo_OrigenInvalido_DestinoValido () {

	falla=false
	
	./moverV5.sh 3.test tests
	
	# Prueba
	if [ -e 3.test ]; then
		echo "Falla: Crea archivo origen" >> ./tests/3.result
		falla=true
	fi
	
	if [ -e ./tests/3.test ]; then
		echo "Falla: Mueve archivo inexistente" >> ./tests/3.result
		falla=true
	fi
	
	resultado "$falla" 3
	limpiar 
	
}


# Test mover archivo valido a directorio valido con duplicado

test_moverArchivo_OrigenDuplicado_DestinoValido () {

	falla=false
	
	# Creacion
	echo "test_4" > 4.test
	echo "test_4" > ./tests/4.test

		
	./moverV5.sh 4.test tests
	
	# Prueba
	if [ -e 4.test ]; then
		echo "Falla: No movido de origen" >> ./tests/4.result
		falla=true
	fi
	
	if [ ! -e ./tests/4.test ]; then
		echo "Falla: Elimina archivo existente en destino" >> ./tests/4.result
		falla=true
	fi
	
	if [ ! -e "./tests/4"[0..*]".test" ]; then
		echo "Falla: No movido origen con cambio de secuenciador" >> ./tests/4.result
		falla=true
	fi
	
	resultado "$falla" 4
	limpiar 
	
}

#MAIN

limpiar; rm -f ./tests/*.result 

test_moverArchivo_OrigenDestinoValidos

test_moverArchivo_OrigenValido_DestinoInvalido 

test_moverArchivo_OrigenInvalido_DestinoValido

test_moverArchivo_OrigenDuplicado_DestinoValido

more ./tests/*  
