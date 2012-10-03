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

# Separadores de tipo de contexto:
CONTEXTO_LINEA="linea"
CONTEXTO_CARACTER="caracter"
SEP_DETALLADOS="+-#-+"

#-------------------------------
# Funciones auxiliares
#-------------------------------

# Funcion que recorta el ultimo caracter de su primer parametro
# Uso: para recortar VAR:
# VAR=`chomp $VAR`
chomp () {
	LONG=`expr length "$1"`
	LONG=`expr $LONG - 1`
	RES=`expr substr "$1" 1 $LONG`
	echo "$RES"
}

# Funcion que elimina el primer y ultimo caracter de su primer parametro
# Uso: Para convertir 'texto' -> texto
# VAR=`recortar_comillas $VAR`
recortar_comillas () {
	LONG=`expr length "$1"`
	AUX=`expr substr "$1" 2 $LONG`
	LONG=`expr $LONG - 2`
	RES=`expr substr "$AUX" 1 $LONG`
	echo "$RES"
}

# Imprime una linea de un archivo.
# Uso: LINEA85=`obtener_linea archivo 85`
obtener_linea () {
	RES=`head -n $2 "$1" | tail -n 1`
	echo "$RES"
}

#-------------------------------
# Programa principal
#-------------------------------

# Verificar si la inicializacion de ambiente
# se realizo anteriormente:
$BINDIR/IniciarV5.sh -inicializado > /dev/null
INICIALIZADO=$? # atrapo el codigo de retorno de IniciarV5
if [ $INICIALIZADO -eq 0 ]; then
	echo "El sistema no fue inicializado.
Debe inicializarlo antes con el comando $BINDIR/IniciarV5."
	exit 1
fi

# Verificar que no haya otra busqueda corriendo:
if ps ax | grep -v grep | grep -v $$ | grep "BuscarV5.sh" > /dev/null
then
    echo "No se puede iniciar porque otra busqueda esta ejecutandose."
    exit 2
fi

# determinar la cantidad de archivos en la carpeta de aceptados
CANT_ARCHIVOS=`find "$ACEPDIR" -type f | wc -l`

STR_CICLO=`grep -e "SECUENCIA2=" < "$CONFDIR/InstalaV5.conf"`
# Calculo la longitud del numero, entre los separadores '='
# y luego corto el string a un auxiliar para extraer el numero
LONG=`expr length "$STR_CICLO"`
AUX_STR_CICLO=`expr substr "$STR_CICLO" 12 $LONG`
POS_SEPARADOR=`expr index "$AUX_STR_CICLO" "="`
LONG_NUMERO=`expr $POS_SEPARADOR - 1`  # $POS_SEPARADOR -= 1
CICLO=`expr substr "$AUX_STR_CICLO" 1 $LONG_NUMERO`  # Corto el string auxiliar y saco el numero solo

# Incremento el secuenciador
CICLO=`expr $CICLO + 1`

# TODO: grabar en el log esto:
echo "Inicio BuscarV5 - Ciclo Nro: $CICLO - Cantidad de archivos: $CANT_ARCHIVOS"

TOTAL_ARCHIVOS=`find "$ACEPDIR" -type f -print | wc -l`
CANT_ARCHS_CON_HALLAZGOS="0"
ARCHS_SIN_PATRON="0"
for archivo in `find "$ACEPDIR" -type f -print`
do
	# TODO: grabar esto en el log:
	echo "Archivo a procesar: $archivo"

	# Analizar si el archivo esta duplicado en PROCDIR,
	# en tal caso rechazarlo.

	# Primero, extraigo el nombre, "rebanando" la ruta por las "/":
	RUTA="$archivo"
	while expr index "$RUTA" "/" > /dev/null
	do
		POSICION=`expr index "$RUTA" "/"`
		LONGITUD=`expr length "$RUTA"`
		INICIO=`expr $POSICION + 1`
		RUTA=`expr substr "$RUTA" $INICIO $LONGITUD`
	done
	NOMBRE="$RUTA"

	# Comprobar si el archivo esta en la carpeta de procesados
	if [ -f "$PROCDIR/$NOMBRE" ]; then
		# El archivo esta duplicado
		echo "Archivo duplicado: $NOMBRE"
		$BINDIR/MoverV5.sh "$archivo" "$RECHDIR"
		# TODO: escribirlo en el log
	else
		# Determinar el codigo de sistema:
		POSICION=`expr index "$NOMBRE" "_"` # El separador es "_"
		LONGITUD=`expr length "$NOMBRE"`
		LONG_COD=`expr $POSICION - 1`
		COD_SIS=`expr substr "$NOMBRE" 1 $LONG_COD`

		# Encontrar los patrones con el codigo de sistema
		CANT_PATRONES=`grep -e "$COD_SIS" < "$MAEDIR/patrones" | wc -l`
		TOTAL_HALLAZGOS="0"
		if [ $CANT_PATRONES -eq 0 ]; then
			# TODO: grabar en el log esto:
			echo "No hay patrones aplicables al archivo"
			ARCHS_SIN_PATRON=`expr $ARCHS_SIN_PATRON + 1`
		else
			# Si se encontraron patrones, los proceso:
			while read linea_patron
			do
				if echo "$linea_patron" | grep -e "$COD_SIS" > /dev/null
				then
					# El registro del patron corresponde al archivo del mismo codigo
					# de sistema.
					EXPR_REG=`echo "$linea_patron" | cut -d, -f2`
					# Elimino las comillas que envuelven a la expresion regular
					# en la linea del archivo de patrones:
					EXPR_REG=`recortar_comillas "$EXPR_REG"`
					# Comienzo a aplicar la expresion regular del mismo codigo
					# de sistema a las lineas del archivo:
					CANT_HALLAZGOS='0'
					PAT_ID=`echo "$linea_patron" | cut -d, -f1`
					NUM_LINEA='0'
					while read linea # lectura linea a linea del archivo de entrada de datos
					do
						NUM_LINEA=`expr $NUM_LINEA + 1`  # NUM_LINEA++
						if echo "$linea" | grep -e "$EXPR_REG" > /dev/null
						then
							# Se encontro una coincidencia:
							CANT_HALLAZGOS=`expr $CANT_HALLAZGOS + 1`
							TOTAL_HALLAZGOS=`expr $TOTAL_HALLAZGOS + 1`

							# Armar el registro para grabarlo, excepto el resultado,
							# que depende del contexto:
							REG="$CICLO$SEP_DETALLADOS$NOMBRE$SEP_DETALLADOS"

							# Determinar los DESDE y HASTA:
							DESDE=`echo "$linea_patron" | cut -d, -f5`
							HASTA=`echo -n "$linea_patron"| cut -d, -f6`
							# Como el campo HASTA esta al final de la linea del
							# archivo de patrones, debo sacar el ultimo caracter
							# que es el de fin de linea:
							HASTA=`chomp "$HASTA"`

							# Determino el tipo de contexto:
							TIPO_CONTEXTO=`echo "$linea_patron" | cut -d, -f4`
							if [ "$TIPO_CONTEXTO" = "$CONTEXTO_CARACTER" ]; then
								LONG_RES=`echo "$HASTA - $DESDE + 1" | bc`
								RESULTADO=`expr substr "$linea" $DESDE $LONG_RES`
								# Grabacion del registro en los resultados
								REG="$REG$NUM_LINEA$SEP_DETALLADOS"
								REG="$REG$RESULTADO"
								echo "$REG" >> "$PROCDIR/resultados.$PAT_ID"
							fi
							if [ "$TIPO_CONTEXTO" = "$CONTEXTO_LINEA" ]; then
								# Debo obtener algunos registros del archivo procesado
								# segun los valores DESDE y HASTA:
								I='0'
								CANT_LINEAS=`echo "$HASTA - $DESDE + 1" | bc`
								LINEA_ACTUAL=$NUM_LINEA
								while [ $I -lt $CANT_LINEAS ]; do
									RESULTADO=`obtener_linea "$archivo" $LINEA_ACTUAL`
									# Grabacion del registro en los resultados
									REG="$REG$LINEA_ACTUAL$SEP_DETALLADOS"
									REG="$REG$RESULTADO"
									echo "$REG" >> "$PROCDIR/resultados.$PAT_ID"
									LINEA_ACTUAL=`echo "$LINEA_ACTUAL + 1" | bc`  # LINEA_ACTUAL++
									I=`echo "$I + 1" | bc`  # I++
								done
							fi
						fi
					done < "$archivo"
					if [ $CANT_HALLAZGOS -eq 0 ]; then
						# No se encontraron hallazgos
						# TODO: grabar en rglobales.pat_id:
						# ciclo,archivo,re,ctx,desde,hasta,cant de hallazgos
						echo
					fi
				fi
			done < "$MAEDIR/patrones"
		fi
		# FIN DE ARCHIVO PROCESADO
		if [ $TOTAL_HALLAZGOS -gt 0 ]; then
			CANT_ARCHS_CON_HALLAZGOS=`expr $CANT_ARCHS_CON_HALLAZGOS + 1`
		fi
		$BINDIR/MoverV5.sh "$archivo" "$PROCDIR"
	fi
done
# FIN DE TODOS LOS ARCHIVOS
ARCHS_SIN_HALLAZGOS=`expr $TOTAL_ARCHIVOS - $CANT_ARCHS_CON_HALLAZGOS`
# TODO: Grabar en el log esto:
echo "Fin del ciclo: $CICLO
Cantidad de archivos con hallazgos: $CANT_ARCHS_CON_HALLAZGOS
Cantidad de archivos sin hallazgos: $ARCHS_SIN_HALLAZGOS
Cantidad de archivos sin patron aplicable: $ARCHS_SIN_PATRON"

exit 0
