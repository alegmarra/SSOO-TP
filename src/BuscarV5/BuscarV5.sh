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
CONTEXTO_LINEA='linea'
CONTEXTO_CARACTER='caracter'
SEP_DETALLADOS='+-#-+'
SEP_GLOBALES=','

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

# Funcion que imprime alguna linea de un archivo.
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

# Determinar la cantidad de archivos en la carpeta de aceptados
CANT_ARCHIVOS=`find "$ACEPDIR" -type f | wc -l`

# Determinar el numero de ciclo:
CICLO=`grep -e "SECUENCIA2=" < "$CONFDIR/InstalaV5.conf" | cut -d= -f2`

# TODO: grabar en el log esto:
echo "Inicio BuscarV5 - Ciclo Nro: $CICLO - Cantidad de archivos: $CANT_ARCHIVOS"

# COMIENZO A PROCESAR LOS ARCHIVOS
TOTAL_ARCHIVOS=`find "$ACEPDIR" -type f -print | wc -l`
CANT_ARCHS_CON_HALLAZGOS="0"
ARCHS_SIN_PATRON="0"
for archivo in `find "$ACEPDIR" -type f -print`
do
	# TODO: grabar esto en el log:
	echo "Archivo a procesar: $archivo"

	# Analizar si el archivo esta duplicado en PROCDIR,
	# en tal caso rechazarlo.

	# Extraigo el nombre del archivo:
	NOMBRE=`basename "$archivo"`

	# Comprobar si el archivo esta en la carpeta de procesados
	if [ -f "$PROCDIR/$NOMBRE" ]; then
		# El archivo esta duplicado
		# TODO: escribir esto en el log:
		echo "Archivo duplicado: $NOMBRE"
		$BINDIR/MoverV5.sh "$archivo" "$RECHDIR"
	else
		# El archivo no fue procesado. Determinar el codigo de sistema:
		COD_SIS=`echo "$NOMBRE" | cut -d_ -f1`

		# Contador de todos los hallazgos de todos los patrones
		# aplicables al archivo
		TOTAL_HALLAZGOS='0'  
		
		# Encontrar los patrones con el codigo de sistema
		CANT_PATRONES=`grep -e "$COD_SIS" < "$MAEDIR/patrones" | wc -l`
		if [ $CANT_PATRONES -eq 0 ]; then
			# No hay patrones aplicables al archivo
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
					
					# Determinar el identificador de patron
					PAT_ID=`echo "$linea_patron" | cut -d, -f1`
					
					# Determinar le expresion regular
					EXPR_REG=`echo "$linea_patron" | cut -d, -f2`
					# Elimino las comillas que envuelven a la expresion regular
					# en la linea del archivo de patrones:
					EXPR_REG=`recortar_comillas "$EXPR_REG"`

					# Determino el tipo de contexto:
					TIPO_CONTEXTO=`echo "$linea_patron" | cut -d, -f4`

					# Determinar los DESDE y HASTA:
					DESDE=`echo "$linea_patron" | cut -d, -f5`
					HASTA=`echo -n "$linea_patron"| cut -d, -f6`
					# Como el campo HASTA esta al final de la linea del
					# archivo de patrones, debo sacar el ultimo caracter
					# que es el de fin de linea ('\n'):
					HASTA=`chomp "$HASTA"`
					
					# Comienzo a aplicar la expresion regular del mismo codigo
					# de sistema a las lineas del archivo:
					CANT_HALLAZGOS='0'					
					NUM_LINEA='1'
					while read linea # lectura linea a linea del archivo de entrada de datos
					do
						if echo "$linea" | grep -e "$EXPR_REG" > /dev/null
						then
							# Se encontro una coincidencia:
							CANT_HALLAZGOS=`expr $CANT_HALLAZGOS + 1`
							if [ "$TIPO_CONTEXTO" = "$CONTEXTO_CARACTER" ]; then
								# Recorto un sector de la linea del archivo:
								LONG_RES=`echo "$HASTA - $DESDE + 1" | bc`
								RESULTADO=`expr substr "$linea" $DESDE $LONG_RES`
								
								# Grabacion del registro en los resultados
								REG="$CICLO$SEP_DETALLADOS$NOMBRE$SEP_DETALLADOS"
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
									# Extraigo una linea entera del archivo:
									RESULTADO=`obtener_linea "$archivo" $LINEA_ACTUAL`
									
									# Grabacion del registro en los resultados:
									REG="$CICLO$SEP_DETALLADOS$NOMBRE$SEP_DETALLADOS"
									REG="$REG$LINEA_ACTUAL$SEP_DETALLADOS"
									REG="$REG$RESULTADO"
									echo "$REG" >> "$PROCDIR/resultados.$PAT_ID"
									LINEA_ACTUAL=`echo "$LINEA_ACTUAL + 1" | bc`  # LINEA_ACTUAL++
									I=`echo "$I + 1" | bc`  # I++
								done
							fi
						fi
						NUM_LINEA=`expr $NUM_LINEA + 1`  # NUM_LINEA++
					done < "$archivo"
					# FIN DE PATRON PARA ESE ARCHIVO
					# Grabar el archivo de resultados globales del patron:
					REG="$CICLO$SEP_GLOBALES$NOMBRE$SEP_GLOBALES"
					REG="$REG$EXPR_REG$SEP_GLOBALES"
					REG="$REG$TIPO_CONTEXTO$SEP_GLOBALES"
					REG="$REG$DESDE$SEP_GLOBALES"
					REG="$REG$HASTA$SEP_GLOBALES"
					REG="$REG$CANT_HALLAZGOS"
					echo "$REG" >> "$PROCDIR/rglobales.$PAT_ID"
					
					TOTAL_HALLAZGOS=`expr $TOTAL_HALLAZGOS + $CANT_HALLAZGOS`
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

# Incremento el secuenciador
CICLO=`expr $CICLO + 1`
# TODO: actualizar en el archivo de configuraciones el ciclo.

exit 0
