#!/bin/sh

#~ -----------------------------------------------
#~ BuscarV5
#~ -----------------------------------------------
#~ Este comando procesa los archivos de logueo aceptados,
#~ aplica los patrones de busqueda apropiados y graba los
#~ resultados en los archivos correspondientes.

# Codigos de retorno:
# 0 - OK
# 1 - El ambiente no está inicializado
# 2 - Otra busqueda se esta ejecutando

# Verificar si la inicializacion de ambiente
# se realizo anteriormente:
$BINDIR/IniciarV5.sh -inicializado > /dev/null
INICIALIZADO=$?
if [ $INICIALIZADO -eq 0 ]; then
	echo "El sistema no fue inicializado.
Debe inicializarlo antes con el comando $BINDIR/IniciarV5."
	return 1
fi

# Verificar que no haya otra busqueda corriendo:
if ps ax | grep -v grep | grep -v $$ | grep "BuscarV5.sh" > /dev/null
then
    echo "No se puede iniciar porque otra busqueda esta ejecutandose."
    return 2
fi

# determinar la cantidad de archivos en la carpeta de aceptados
CANT_ARCHIVOS=$(find "$ACEPDIR" -type f | wc -l)

STR_CICLO=$(grep -e "SECUENCIA2=" $CONFDIR/InstalaV5.conf)
# Calculo la longitud del numero, entre los separadores '='
# y luego corto el string a un auxiliar para extraer el numero
LONG=$(expr length "$STR_CICLO")
AUX_STR_CICLO=$(expr substr "$STR_CICLO" 12 $LONG)
POS_SEPARADOR=$(expr index "$AUX_STR_CICLO" "=")
LONG_NUMERO=$( echo "$POS_SEPARADOR-1" | bc) # $POS_SEPARADOR -= 1
CICLO=$(expr substr "$AUX_STR_CICLO" 1 $LONG_NUMERO) # Corto el string auxiliar y saco el numero solo

# Incremento el secuenciador
CICLO=$(echo "$CICLO + 1" | bc)

# TODO: grabar en el log esto:
echo "Inicio BuscarV5 - Ciclo Nro: $CICLO - Cantidad de archivos: $CANT_ARCHIVOS"

CANT_ARCHS_CON_HALLAZGOS="0"
TOTAL_ARCHIVOS=$(find "$ACEPDIR" -type f -print | wc -l)
ARCHS_SIN_PATRON="0"
for archivo in $(find "$ACEPDIR" -type f -print); do
	# TODO: grabar esto en el log:
	echo "Archivo a procesar: $archivo"
	
	# Analizar si el archivo esta duplicado en PROCDIR,
	# en tal caso rechazarlo.
	
	# Primero, extraigo el nombre, "rebanando" la ruta por las "/":
	RUTA=$archivo
	while expr index "$RUTA" "/" > /dev/null
	do
		POSICION=$(expr index "$RUTA" "/")
		LONGITUD=$(expr length "$RUTA")
		INICIO=$(echo "$POSICION + 1" | bc)
		RUTA=$(expr substr "$RUTA" $INICIO $LONGITUD)
	done
	NOMBRE=$RUTA
	
	# Comprobar si el archivo esta en la carpeta de procesados
	if [ -f "$PROCDIR/$NOMBRE" ]; then
		# El archivo esta duplicado
		echo "Archivo duplicado: $NOMBRE"
		$BINDIR/MoverV5.sh "$archivo" "$RECHDIR"
		# TODO: escribirlo en el log
	else
		# Determinar el codigo de sistema:
		POSICION=$(expr index "$NOMBRE" "_") # El separado es "_"
		LONGITUD=$(expr length "$NOMBRE")
		LONG_COD=$(echo "$POSICION - 1" | bc)
		COD_SIS=$(expr substr "$NOMBRE" 1 $LONG_COD)
		
		# Encontrar los patrones con el codigo de sistema
		#echo "DEBUG: el codigo es $COD_SIS"
		CANT_PATRONES=$(grep -e "$COD_SIS" "$MAEDIR/patrones" | wc -l)
		TOTAL_HALLAZGOS="0"
		if [ $CANT_PATRONES -eq 0 ]; then
			# TODO: grabar en el log esto:
			echo "No hay patrones aplicables al archivo"
			ARCHS_SIN_PATRON=$( echo "$ARCHS_SIN_PATRON + 1" | bc)
		else
			# Si se encontraron patrones, los proceso:
			for expr_reg in $( grep -e "$COD_SIS" "$MAEDIR/patrones" | cut -d, -f2 )
			do
				# Comienzo a aplicar la expresion regular del mismo codigo
				# de sistema a las lineas del archivo:
				echo "DEBUG: re a aplicar: $expr_reg en $archivo"
				CANT_HALLAZGOS="0"
				while read linea # lectura linea a linea del archivo
				do
					#echo "DEBUG: leido: $linea"
					if echo "$linea" | grep -e "$expr_reg" > /dev/null
					then
						# Se encontro una coincidencia:
						CANT_HALLAZGOS=$(echo "$CANT_HALLAZGOS + 1" | bc)
						TOTAL_HALLAZGOS=$(echo "$TOTAL_HALLAZGOS + 1" | bc)
						echo "DEBUG: encontrado $CANT_HALLAZGOS en: $linea"
						# TODO: recordar de alguna forma la coincidencia para despues
						# grabar el registro.
					fi
				done < $archivo
				if [ $CANT_HALLAZGOS -eq 0 ]; then
					# No se encontraron hallazgos
					echo "DEBUG: no hay hallazgos para $expr_reg en $archivo"
					
				fi
			done
		fi
		# FIN DE ARCHIVO PROCESADO
		if [ $TOTAL_HALLAZGOS -gt 0 ]; then
			CANT_ARCHS_CON_HALLAZGOS=$(echo "$CANT_ARCHS_CON_HALLAZGOS + 1" | bc)
		fi
		$BINDIR/MoverV5.sh "$archivo" "$PROCDIR"		
	fi
done
# FIN DE TODOS LOS ARCHIVOS
# TODO: Grabar en el log esto:
ARCHS_SIN_HALLAZGOS=$(echo "$TOTAL_ARCHIVOS - $CANT_ARCHS_CON_HALLAZGOS" | bc)
echo "Fin del ciclo: $CICLO
Cantidad de archivos con hallazgos: $CANT_ARCHS_CON_HALLAZGOS
Cantidad de archivos sin hallazgos: $ARCHS_SIN_HALLAZGOS
Cantidad de archivos sin patron aplicable: $ARCHS_SIN_PATRON"

return 0
