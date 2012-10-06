#!/bin/bash


# Test suite para moverV5.sh

resultado (){

	destino="./tests/brief.result"

	if ! "$1" ; then
		echo "TEST $2 OK" >> "$destino"
	else
		echo "TEST $2 FAILED" >> "$destino"
	fi

}

limpiar () {
	
	rm -f ./*.test
	find ./tests -type f ! -name '*.result' | xargs rm -f
}

# Test mover archivo valido a directorio valido, sin duplicado

test_moverArchivo_OrigenDestinoValidos () {
	
	falla=false

	# Creacion
	echo "test_1" > 1.test
	echo "Origen - Destino Validos" >> ./tests/1.result

	./moverV5.sh 1.test tests "Loguear"
	
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
	echo "test_2" >> 2.test
	echo "Origen Valido - Destino Invalido" >> ./tests/2.result
	
	./moverV5.sh 2.test inexistente "Loguear"

	
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
	
	echo "Origen Invalido - Destino Valido" >> ./tests/3.result

	./moverV5.sh 3.test tests "Loguear"

	
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
	echo "Origen duplicado en Destino" >> ./tests/4.result

		
	./moverV5.sh 4.test tests "Loguear"

	
	# Prueba
	if [ -e 4.test ]; then
		echo "Falla: No movido de origen" >> ./tests/4.result
		falla=true
	fi
	
	if [ ! -e ./tests/4.test ]; then
		echo "Falla: Elimina archivo existente en destino" \
		>> ./tests/4.result
		falla=true
	fi
	
	if [ ! -e "./tests/4.test."[0-9+] ]; then
		echo "Falla: No movido origen con cambio de secuenciador" \
		>> ./tests/4.result
		falla=true
	fi
	
	resultado "$falla" 4
	limpiar 
}

# Test mover origen igual destino 

test_moverArchivo_OrigenDestinoInvalidos_Iguales () {

	falla=false
	
	# Creacion
	echo "test_5" >> 5.test
	echo "Origen - Destino Iguales" >> ./tests/5.result

	./moverV5.sh ./5.test ./ "Loguear"
	salida=$?
	
	# Prueba
	if [[ ! -e 5.test ]]; then
		echo "Falla: Reemplaza archivo de origen" \
		>> ./tests/5.result
		falla=true
	fi
	
	if [[ $salida -ne 1 ]]; then
		echo "Falla: No retorna con error" \
		>> ./tests/5.result
		falla=true
	fi

	resultado "$falla" 5
	limpiar 
	
}



#MAIN
limpiar; rm -f ./tests/*.result ./mover.log

test_moverArchivo_OrigenDestinoValidos

test_moverArchivo_OrigenValido_DestinoInvalido 

test_moverArchivo_OrigenInvalido_DestinoValido

test_moverArchivo_OrigenDuplicado_DestinoValido

test_moverArchivo_OrigenDestinoInvalidos_Iguales

cat ./tests/brief.result  
