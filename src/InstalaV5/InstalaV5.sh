#!/bin/bash

###################################################################
## Script de Instalacion de Sistemas de Administracion de Logueo
##
###################################################################


#####################################################
# Declaracion y Definicion de Variables Principales #
#####################################################

NOM_ARCH_ERRORES="ListaErrores"

NOM_ARCH_LOG="InstalaV5.log"

NOM_ARCH_CONFIG="InstalaV5.conf"
NOM_ARCH_DE_INSTALACION="arch-sistema.dat"
DIR_ARCH_DE_INSTALACION="dir_arch_instalacion"

ESTADO_INSTALACION="I" # 3 estados (INCOMPLETO(I), PARCIAL(P), COMPLETO(C))


# Declaracion de Variables para que sea compatible con bash 3.0

GRUPO=0
CONFDIR=1
BINDIR=2
MAEDIR=3
ARRIDIR=4
ACEPDIR=5
RECHDIR=6
PROCDIR=7
REPODIR=8
LOGDIR=9
LOGEXT=10
LOGSIZE=11
DATASIZE=12
SECUENCIA1=13
SECUENCIA2=14

declare -a NOM_VARIABLES=(GRUPO CONFDIR BINDIR MAEDIR ARRIDIR ACEPDIR RECHDIR PROCDIR REPODIR LOGDIR LOGEXT LOGSIZE DATASIZE SECUENCIA1 SECUENCIA2)

declare -a DESCRIP_DIR=( [$CONFDIR]="Directorio donde se encuentran los archivos de Configuracion del Sistema" \
	[$BINDIR]="directorio de archivos ejecutables" \
	[$MAEDIR]="directorio de archivos Maestros" \
	[$ARRIDIR]="directorio de arribo de archivos externos" \
	[$ACEPDIR]="directorio de grabacion de los archivos externos aceptados" \
	[$RECHDIR]="directorio de grabacion de archivos rechazados" \
	[$PROCDIR]="directorio de grabacion de los archivos procesados" \
	[$REPODIR]="directorio de grabacion de los reportes de salida" \
	[$LOGDIR]="directorio de grabacion de los logs del sistema" \
	)

declare -a DESCRIP_DIR_RES=( ["$CONFDIR"]="Libreria del Sistema" \
	[$BINDIR]="Ejecutables" \
	[$MAEDIR]="Archivos Maestros" \
	[$ARRIDIR]="Arribo de archivos externos" \
	[$ACEPDIR]="Archivos Externo Aceptados" \
	[$RECHDIR]="Archivos Externos Rechazados" \
	[$PROCDIR]="Archivos procesado" \
	[$REPODIR]="Reportes de Salida" \
	[$LOGDIR]="Logs de auditoria del Sistema" \
	)

declare -a VARIABLES=( [$CONFDIR]="conf" )

DIR_INSTALADOS=false

# Variables agregadas para que funcione con bash 3.0

IniciarV5=0
DetectaV5=1
BuscarV5=2
ListarV5=3
MoverV5=4
LoguearV5=5
MirarV5=6
StopD=7
StartD=8
DetenerV5=11

NOM_COM=(IniciarV5 DetectaV5 BuscarV5 ListarV5 MoverV5 LoguearV5 MirarV5 StopD StartD DetenerV5)
#declare -a COM_INSTALADOS=( [${!NOM_COM[0]}]=false [${!NOM_COM[1]}]=false [${!NOM_COM[2]}]=false [${!NOM_COM[3]}]=false \
	#[${!NOM_COM[3]}]=false [${!NOM_COM[4]}]=false [${!NOM_COM[5]}]=false [${!NOM_COM[6]}]=false \
	#[${!NOM_COM[7]}]=false [${!NOM_COM[8]}]=false [${!NOM_COM[9]}]=false)

declare -a COM_INSTALADOS=( [0]=false [1]=false [2]=false [3]=false \
	[3]=false [4]=false [5]=false [6]=false \
	[7]=false [8]=false [11]=false)



# Variables agregadas para que funcione con bash 3.0
patrones=9
sistemas=10

ARCH_MAESTROS=( patrones sistemas )
declare -a ARCH_MAE_INSTALADOS=( [9]=false [10]=false )

## Variables utilizadas para los valores de retorno de una funcion
RETORNO=""
RETORNO_2=""

########################################################################
########################################################################
##								      ##
##		Definicion de funciones utilizadas		      ##
##								      ##
########################################################################
########################################################################

#########################################################################
# Funcion de echo para modo de Depuracion
# Arg0: Mensaje a mostrar
# Arg1: Numero de etapa (solo se muestran los msj con el mismo numero de etapa)
function echo_depuracion {
	if [ "$2" == "3" ]; then
		echo $1
	fi
	return 0
}

##########################################################################
##
## Funcion que almacena el string parametro en el archivo de log y lo
## muesta en pantalla
## Arg0: Mensaje a procesar en el "log"
## Arg1(Opcional): puede ser "-nm" (no mostrar) para no imprimir el 
## mensaje por salida estandard

function mostrar_y_registrar {
	declare local msj=$1
	declare local registro
	
	fecha=`date +"%0d/%0m/%Y %I:%M%p"`

	if [ "$2" != "-nm" ]; then
		echo "$msj"
	fi
	
	registro="$fecha;$USERNAME;I;InstalaV5;$msj"
	
	echo "$registro" >> "$NOM_ARCH_LOG"

	return 0
}

##########################################################################
##
## Busca un archivo en todos los subdirectorios partir del actual, si no lo encuentra retorna un string nulo
## Arg0: nombre del archivo a buscar
## RETORNO: ruta completa del archivo encontrado, desde el directorio actual.

function buscar_archivo_config {
	#declare local a_buscar=$1

	#find > aux.out

	#grep ".*${a_buscar}$" aux.out > aux-2.out  

	#if [ $? -eq 0 ];then
		#read RETORNO < aux-2.out
	#else
		#RETORNO=""
	#fi
	
	#rm aux.out
	#rm aux-2.out
	
	if [ -f "${VARIABLES[$CONFDIR]}/$NOM_ARCH_CONFIG" ];then
		RETORNO="${VARIABLES[$CONFDIR]}/$NOM_ARCH_CONFIG"
	else
		RETORNO=""
	fi	
	
	return 0

}

############################################################################
##
## Funcion que crea las carpetas del sistema

function crear_carpetas {
	declare nom_var
	declare local nom_dir
	
	mostrar_y_registrar "Se inicia la creacion de directorios." -nm
	
	for nom_var in "${!NOM_VARIABLES[@]}";do
	
		if [ -n  "${DESCRIP_DIR[$nom_var]}" ]; then
			nom_dir="${VARIABLES[$nom_var]}"
			if [ ! -d "$nom_dir" ]; then
				mkdir -p "$nom_dir"
				mostrar_y_registrar "Se creo el directorio/s \"$nom_dir\"" -nm
			fi
		fi
	done
	
	DIR_INSTALADOS=true
	
	mostrar_y_registrar "Finaliza la creacion de directorios." -nm
	
	## copia el archivo de errores a BINDIR
	
	if [ -f "${DIR_ARCH_DE_INSTALACION}/$NOM_ARCH_ERRORES" ]; then
		cp "${DIR_ARCH_DE_INSTALACION}/$NOM_ARCH_ERRORES" "${VARIABLES[$BINDIR]}"
		mostrar_y_registrar "Copiado archivo de errores al directorio ${VARIABLES[$BINDIR]}." -nm
	fi

	return 0
}

############################################################################

# Solicitar ingreso de dato por entrada estandar, si solo se ingresa un enter, se utiliza como
# dato valido el valor por defecto
# Arg0 : Mensaje descripcion del directorio
# Arg1 : Nombre del directorio por defecto

function leer_entrada {

	declare local nom_dir;

	echo "${1} (${2}):"; 
	read nom_dir;
	
	if [ -z "$nom_dir" ]
	then	
		nom_dir=$2;
	fi

	RETORNO=$nom_dir	

	return 0
}
#####################################################################
##
## Carga los valores por defecto de la variable de ambiente
##

function cagar_valores_defecto {
	declare local ruta
	ruta=`pwd`
	
	mostrar_y_registrar "Se establecen las variables con sus valores por defecto." -nm
	
	VARIABLES[$GRUPO]="$ruta"
	VARIABLES[$CONFDIR]="conf"
	VARIABLES[$BINDIR]="bin"
	VARIABLES[$MAEDIR]="mae"
	VARIABLES[$ARRIDIR]="arribos"
	VARIABLES[$ACEPDIR]="aceptados"
	VARIABLES[$RECHDIR]="rechazados"
	VARIABLES[$PROCDIR]="procesados"
	VARIABLES[$REPODIR]="reportes"
	VARIABLES[$LOGDIR]="log"

	VARIABLES[$LOGEXT]="log"
	VARIABLES[$LOGSIZE]=400
	VARIABLES[$DATASIZE]=150

	VARIABLES[$SECUENCIA1]=0
	VARIABLES[$SECUENCIA2]=0
	
	mostrar_y_registrar "Fin de establecer las variables con sus valores por defecto." -nm
	
	return 0
}


#########################################################################
##
## Muestra los valores de las variables actuales para los directorios
## 
function mostrar_valores_ingresados {
	declare local nom_var=""
	declare local decripcion=""
	
	mostrar_y_registrar "Se inicia el proceso de muestreo de valores ingresados por el usuario." -nm
	
	for nom_var in "${!NOM_VARIABLES[@]}"; do
		
		descripcion="${DESCRIP_DIR[$nom_var]}"
		

		if [ -n "$descripcion" ]; then
			echo "-${descripcion}: "${VARIABLES[$nom_var]}
			echo
			if [ "$nom_var" == "$ARRIDIR" ]; then
				echo "--Espacio para el arribo de archivos externos: ${VARIABLES[$DATASIZE]} Mb"
				echo
			fi
			
		fi

	done
	
	echo "-Logs de auditoria del Sistema: ${VARIABLES[$LOGDIR]}/<comando>.${VARIABLES[$LOGEXT]}"
	echo

	echo "--Tamaño maximo para los archivo de log del sistema: ${VARIABLES[$LOGSIZE]} kb"

	
	mostrar_y_registrar "Finaliza el proceso de muestreo de valores ingresados por el usuario." -nm
}

########################################################################
##
## Guarda la configuracion del sistema dentro del directorio del sistema
##
function guardar_configuracion {
	declare local var
	declare local fecha_creacion
	declare local registro
	declare local valor
	declare local usuario
	
	mostrar_y_registrar "Se incia el proceso de almacenamiento de la configuracion del sistema." -nm
	
	usuario="$USER"
	
	fecha_creacion=`date +"%0d/%0m/%Y %I:%M%p"`
	
	if [ -d "${VARIABLES[$CONFDIR]}" ]; then
		cd "${VARIABLES[$CONFDIR]}"
		if [ ! -f "$NOM_ARCH_CONFIG" ]; then
			: > "$NOM_ARCH_CONFIG"
		fi

		# Guarda los Variables principales
		
		for var in "${NOM_VARIABLES[@]}";do
		
			valor="${VARIABLES[${!var}]}"
			grep "^${var}.*" "$NOM_ARCH_CONFIG" > aux
			
			
			
			if [ $? -eq 0 ]; then
				# Sustituyo el nuevo registro por el viejo por ER (expresiones regulares)
				# el simbolo separador de la Expresion regular es +

				if [ -n "${DESCRIP_DIR[${!var}]}" ]; then
					sed "s+${var}=\(.*\)=\(.*\)=\(.*\)+${var}=${VARIABLES[$GRUPO]}/${valor}=\2=${fecha_creacion}+" \
					"$NOM_ARCH_CONFIG" > aux
				else
					sed "s+${var}=\(.*\)=\(.*\)=\(.*\)+${var}=${valor}=\2=${fecha_creacion}+" \
					"$NOM_ARCH_CONFIG" > aux
				fi
				mv aux "$NOM_ARCH_CONFIG"
				
			elif [ -n "${DESCRIP_DIR[${!var}]}" ]; then

				if [ "${!var}" == "$GRUPO" ]; then
					registro="${var}=${VARIABLES[$GRUPO]}=$usuario=${fecha_creacion}"
				else
					registro="${var}=${VARIABLES[$GRUPO]}/${valor}=$usuario=${fecha_creacion}"
				fi
				echo "$registro" >> "$NOM_ARCH_CONFIG"
			else
				registro="${var}=${valor}=$usuario=${fecha_creacion}"
				echo "$registro" >> "$NOM_ARCH_CONFIG"
			fi
					
		done
		
		cd ..
		mostrar_y_registrar "Se guardaron todas las variables del sistema." -nm
		cd "${VARIABLES[$CONFDIR]}"
		
		# Guardo las datos de instalacion particulares
		for var in "${NOM_COM[@]}"; do
			
			if [ "${COM_INSTALADOS[${!var}]}" == "true" ]; then
				grep "^COMANDO=${var}.*" "$NOM_ARCH_CONFIG" > aux
				
				if [ "$?" != "0" ]; then				
					registro="COMANDO=${var}=INSTALADO=$fecha_creacion"
					echo "$registro" >> "$NOM_ARCH_CONFIG"
				fi
			fi

		done
		
		cd ..
		mostrar_y_registrar "Se guardaron los comandos instalados del sistema." -nm
		cd "${VARIABLES[$CONFDIR]}"
		
		for var in "${ARCH_MAESTROS[@]}"; do
			
			if [ "${ARCH_MAE_INSTALADOS[${!var}]}" == "true" ]; then
				grep "^ARCHIVO=${var}.*" "$NOM_ARCH_CONFIG" > aux
				
				if [ "$?" !=  "0" ]; then
					registro="ARCHIVO=${var}=INSTALADO=$fecha_creacion"
					echo "$registro" >> "$NOM_ARCH_CONFIG"
				fi
			fi

		done
		
		cd ..
		mostrar_y_registrar "Se guardaron los archivos maestros instalados del sistema." -nm
		cd "${VARIABLES[$CONFDIR]}"
		
		if [ "$DIR_INSTALADOS" == "true" ]; then
			grep "^DIRECTORIOS=INSTALADOS=.*" "$NOM_ARCH_CONFIG" > aux
			if [ "$?" != "0" ]; then
				registro="DIRECTORIOS=INSTALADOS=$fecha_creacion"
				echo "$registro" >> "$NOM_ARCH_CONFIG"
			fi 
		fi
		
		
		if [ -f aux ]; then
			rm aux
		fi
			
		cd ..
	else
		echo "Error al guardar configuracion: No existe carpeta de configuracion"
	fi
	
	mostrar_y_registrar "Finaliza el proceso de almacenamiento de la configuracion del sistema." -nm
	
	return 0
}

#########################################################################
##
## Carga las variables principales del Sistema
## Arg0: ruta del archivo de configuracion
##
function cargar_configuracion {
		
	mostrar_y_registrar "Se inicia la carga de la configuracion del sistema." -nm

	declare local ruta_arch=$1
	declare local nom_var
	declare local dir_instalado

	declare local nom_com
	declare local com_instalado

	declare local nom_arch
	declare local arch_instalado
	declare local grupo	
	
	if [ -f "$ruta_arch" ]; then
		grupo=`grep "^GRUPO" "$ruta_arch" | cut -d "=" -f 2` 
		
		VARIABLES[$GRUPO]="$grupo"

		
		for nom_var in "${NOM_VARIABLES[@]}"; do
			dir_instalado=`grep "^${nom_var}.*" "$ruta_arch" | cut -d "=" -f 2`
			

			if [ "${!nom_var}" != "$GRUPO" ] && [ -n "${DESCRIP_DIR[${!nom_var}]}" ]
			then
				VARIABLES[${!nom_var}]="${dir_instalado/${grupo}\/}"
				if [ ! -d "${dir_instalado}" ]; then
					mkdir -p "${dir_instalado}"
				fi
			else
				VARIABLES[${!nom_var}]="${dir_instalado}"
			fi

		done
		
	
		grep "^COMANDO=.*" "$ruta_arch" > comandos.dat

		for nom_com in "${NOM_COM[@]}"; do
			grep ".*=${nom_com}=.*" comandos.dat > aux
			cut -d "=" -f 3 aux > aux2
			read com_instalado < aux2


			if [ "${com_instalado}" == "INSTALADO" ] && \
			[ -f "${VARIABLES[$GRUPO]}/${VARIABLES[$BINDIR]}/${nom_com}"* ] || \
			[ -f "${VARIABLES[$GRUPO]}/${nom_com}"* ]
			then
				COM_INSTALADOS[${!nom_com}]=true
			else
				COM_INSTALADOS[${!nom_com}]=false
			fi
		done
	

		grep "^ARCHIVO.*" "$ruta_arch" > archivos.dat

		for nom_arch in "${ARCH_MAESTROS[@]}"; do
			grep ".*=${nom_arch}=.*" archivos.dat > aux
			cut -d "=" -f 3 aux > aux2
			read arch_instalado < aux2

			if [ "${arch_instalado}" == "INSTALADO" ] && \
			[ -f "${VARIABLES[$GRUPO]}/${VARIABLES[$MAEDIR]}/${nom_arch}" ]
			then
				ARCH_MAE_INSTALADOS[${!nom_arch}]=true
			else
				ARCH_MAE_INSTALADOS[${!nom_arch}]=false
			fi
		done
		
		grep "^DIRECTORIOS=INSTALADOS.*" "$ruta_arch" > aux
		
		if [ $? -eq 0 ]; then
			DIR_INSTALADOS=true
		fi
		
		rm comandos.dat
		rm archivos.dat		
		rm aux
		rm aux2
		
		if [ -d "${VARIABLES[$BINDIR]}" ]; then
			if [ ! -f "${VARIABLES[$BINDIR]}"/ListaErrores ]; then
				cp "$DIR_ARCH_DE_INSTALACION"/ListaErrores "${VARIABLES[$BINDIR]}"
			fi
		fi

	else
		echo_depuracion "Archivo de configuracion no existe" 0
	fi
	
	mostrar_y_registrar "Finalizo la carga de la configuracion del sistema." -nm
	
}

########################################################################
##
## Funcion que carga los nombre de las variables
## 

function establecer_variables {
	declare local mensaje=""
	declare local continuar_leyendo=true

	mostrar_y_registrar "Se inicia el proceso de definir las variables globales del sistema." -nm

	for nom_var in "${NOM_VARIABLES[@]}"; do

		mensaje=${DESCRIP_DIR[${!nom_var}]}
		
		if [ -n "${mensaje}" ] && [ "${!nom_var}" != "$LOGDIR" ] && [ "${!nom_var}" != "$CONFDIR" ]
		then
			
			mensaje="Definir el "${mensaje}
			
			while [ "$continuar_leyendo" == "true" ]; do
				leer_entrada "$mensaje" "${VARIABLES[${!nom_var}]}"
			
				echo "$RETORNO" | grep "=" > /dev/null

				if [ "$?" != "0" ]; then				
					VARIABLES[$nom_var]=$RETORNO
					mostrar_y_registrar "Definido el valor \"$RETORNO\" para variable \"${nom_var}\"" -nm
					continuar_leyendo=false
				else
					echo
					echo " * El nombre del directorio no puede contener el caracter \"=\""
				fi
			done
			continuar_leyendo=true
		fi
	done;
	
	mostrar_y_registrar "Se finalizo el proceso de definir las variables globales del sistema." -nm
	return 0
}

#########################################################################
##
## Funcion que comprueba si hay cierta cantidad de espacio suficiente en
## el disco actual
##
## Arg0: cantidad de espacio requerida para la comparacion
## RETORNO: true si hay espacio mayor o igual al parametro, false sino
## RETORNO_2: espacio libre en la particion actual
function hay_espacio_suficiente {
	
	declare local tam_a_comp=$1
	declare local particion_disco='/$'
	declare local tam_actual
	
	mostrar_y_registrar "Comienza la comprobacion del espacio en disco." -nm
	
	## ...
	## compara si se esta en otra particion
	
	tam_actual=`df -B 1000000 2> /dev/null | grep "$particion_disco" | awk '{ print $4 }' | head -1`
	
	
	if [ $tam_a_comp -le $tam_actual ] && [ $tam_a_comp -gt 0 ]; then
		RETORNO=true
	else
		RETORNO=false
	fi


	RETORNO_2=$tam_actual

	return 0
}
#########################################################################
##
## Funcion que pregunta por los datos numericos configurables del sistema
##

function establecer_variables_num {
	
	declare local msj=""	
	declare local espacio_suficiente=false
	declare local espacio_libre
	declare local valor

	mostrar_y_registrar "Se inicia el proceso de definir las variables globales de tipo numerico del sistema." -nm

	msj="Defina el espacio mínimo libre para el arribo de archivos externos en Mbytes"

	while [ "$espacio_suficiente" == false ]; do

		leer_entrada "$msj" "${VARIABLES[$DATASIZE]}"
		valor=$RETORNO
		
		echo "$valor" | grep "[^0-9]" > /dev/null

		if [ "$?" != "0" ] || [ -z "$valor" ] ; then
		
			hay_espacio_suficiente $valor
		
			if [ "$RETORNO" == "true" ]; then
				espacio_suficiente=true
				VARIABLES[$DATASIZE]=$valor	
				mostrar_y_registrar "Definido $valor Mb para espacio de arch de arribo." -nm	
			else
			
				if [ $valor -eq 0 ]; then
					echo "Ingrese un valor mayor que cero."
				else
					echo "Insuficiente Espacio en Disco."
				fi

				echo "Espacio Disponible: $RETORNO_2 Mb"

				if [ "$valor" != "0" ]; then
					echo "Espacio Requerido: $valor Mb"
				fi

				echo "Cancela Instalación e intentelo mas tarde o vuelva intentarlo con otro valor."
			
				mostrar_y_registrar "Tam Ingresado para disco, insuficiente. Tam actual: $RETORNO_2 Mb. Ingresado: $valor Mb." -nm
			
				confirmar_respuesta "¿Ingresar otro valor?"
			
				if [ "$RETORNO" == "false" ]; then
					finalizar_instalacion 1			
				fi
			
			fi
		else
			echo
			echo " * Solo se permite el ingreso de caracteres numericos"
		fi
	done
	
	
	msj="Defina el tamaño maximo para los archivos de log, en Kb"
	
	espacio_suficiente=false

	while [ "$espacio_suficiente" == false ]; do
		leer_entrada "$msj" "${VARIABLES[$LOGSIZE]}"
	
		echo "$RETORNO" | grep "[^0-9]" > /dev/null

		if [ "$?" != "0" ] || [ -z "$RETORNO" ]; then				
			VARIABLES["$LOGSIZE"]=$RETORNO
			mostrar_y_registrar "Definido $RETORNO Kb para tamaño max de archivos de log." -nm
			espacio_suficiente=true
		else
			echo
			echo " * Solo se permite el ingreso de caracteres numericos"
		fi
	done

	mostrar_y_registrar "Se finalizo el proceso de definir las variables globales de tipo numerico del sistema." -nm
	return 0
}

########################################################################
##
## Funcion que para un mensaje tiene que decir por si o por no, retornando
## true si la respuesta fue "si" o no en caso contrario

function confirmar_respuesta {
	declare local msj
	declare local resp_correcta=false
	declare local resp
	msj="${1} ( S(s) / N(n) )"
	
	while [ "$resp_correcta" == false ]; do 
	
		echo "$msj"
		read resp

		if [ "$resp" == 's' ] || [ "$resp" == 'S' ]; then
			RETORNO=true
			resp_correcta=true
		elif [ "$resp" == 'n' ] || [ "$resp" == 'N' ]; then
			RETORNO=false
			resp_correcta=true
		else
			echo "Respuesta incorrecta, ingrese \"S(s)\" o \"N(n)\""
		fi

	done

	return 0
}

########################################################################
##
## Funcion que comprueba que perl esta instalado
## RETORNO: true si perl se encuentra instalado en el sistema, false sino.
##
function verificar_perl_instalado {
	
	declare local ruta_perl
	ruta_perl=`which perl`
	declare version
	declare version_a_comp
	
	mostrar_y_registrar "Se inicia comprobacion de Perl." -nm
	
	if [ -n "$ruta_perl" ]; then
		version=`perl --version | grep "v[0-9]\.*" | sed "s+\(.*\)v\([0-9]*\.[0-9]*\)\(.*\)+\2+gi"` 
		version_a_comp=`echo "$version" | sed "s+\(^\)\([0-9]\)\(.*\)+\2+"`
		
		if [ $version_a_comp -ge 5 ]; then
			RETORNO=true
		else
			RETORNO=false
		fi
	else
		RETORNO=false
	fi	
		
	if [ "$RETORNO" == "false" ];then
		echo "Perl no se encuentra instalado. Se necesita tener Perl 5 o superior"
		echo "Instale Perl en su sistema e inicie nuevamente la instalacion"
		mostrar_y_registrar "Perl no se encuentra instalado o tiene una version inferior a 5" -nm
		finalizar_instalacion 1
	else
		mostrar_y_registrar "Perl se encuentra instalado, version: $version"
	fi

	mostrar_y_registrar "Finaliza comprobacion de Perl en el sistema." -nm
	
	return 0
}



################################################################
##
## Instala componentes del sistema
##

function instalar_sistema {
	
	declare local comp_a_inst
	
	mostrar_y_registrar "Se inicia la instalacion completa del sistema" -nm

	echo "Creando Estructuras de Directorios..."
	crear_carpetas
	
	echo "Instalando Archivos Maestros..."
	mostrar_y_registrar "Se inicia la instalacion de los archivos maestros." -nm

	for comp_a_inst in "${ARCH_MAESTROS[@]}"; do
		instalar_componente "$comp_a_inst"
	done
	mostrar_y_registrar "Finaliza la instalacion de los archivos maestros." -nm

	echo "Instalando Programas y Funciones..."
	
	mostrar_y_registrar "Se inicia la instalacion de los comandos." -nm

	for comp_a_inst in "${NOM_COM[@]}"; do
		instalar_componente "$comp_a_inst"
	done
	mostrar_y_registrar "Finaliza la instalacion de los comandos." -nm
	
	echo "Actualizando la configuracion del sistema..."
	guardar_configuracion
	
	echo
	mostrar_y_registrar "Instalacion realizada exitosamente."

	return 0
}


########################################################################
## Repara los componentes faltantes en el sistema
## 

function reparar_sistema {

	declare local com
	declare local arch	

	mostrar_y_registrar "Se inicia la reparacion del sistema."
	
	echo 
	echo "Instalando componentes faltantes..."
	echo
	
	for com in "${NOM_COM[@]}"; do
		if [ "${COM_INSTALADOS[${!com}]}" == false ]; then
			instalar_componente "$com"
		fi

	done

	for arch in "${ARCH_MAESTROS[@]}"; do
		if [ "${ARCH_MAE_INSTALADOS[${!arch}]}" == false ]; then
			instalar_componente "$arch"
		fi
	done
	
	mostrar_y_registrar "Finaliza la repacion del sistema." -nm
	mostrar_y_registrar "Sistema reparado existosamente."

	return 0
}

########################################################################
##
## Funcion que retorna un booleano indicando si existe o no dentro del 
## sistema el componente pasado como argumento(No si esta instalado, si
## es parte del sistema.)
## Arg0: componente a comprobar su existencia
## RETORNO: "true" si existe, "false" si no

function existe_componente {
	
	declare local existe=false
	declare local componente=$1
	declare local i=0
	while [ $existe == false ] && [ $i -lt ${#NOM_COM[@]} ]; do
		if [ "${NOM_COM[$i]}" == "$componente" ]; then
			existe=true;
		fi
		let i=$i+1
	done
	
	i=0
	
	while [ $existe == false ] && [ $i -lt ${#ARCH_MAESTROS[@]} ]; do
		if [ "${ARCH_MAESTROS[$i]}" == "$componente" ]; then
			existe=true;
		fi
		let i=$i+1
	done
	
	
	RETORNO=$existe
	
	return 0
}

########################################################################
## Instala el componente pasado como argumento que puede un comando o
## un archivo.
## Arg0: nombre del componente a instalar
## RETORNO: string con una descripcion del proceso del instalacion

function instalar_componente {
	declare local comp_a_inst=$1
	declare local dir="$DIR_ARCH_DE_INSTALACION"
	if [ -n "${COM_INSTALADOS[${!comp_a_inst}]}" ]; then
		if [ -d "${VARIABLES[$BINDIR]}" ]; then
			if [ "${COM_INSTALADOS[${!comp_a_inst}]}" == false ]; then
				## Copiar el desde la fuente el archivo orignal a la carpeta de maestros
				if [ ${!comp_a_inst} -eq $IniciarV5 ] || [ ${!comp_a_inst} -eq $DetenerV5 ];then
					cp ${dir}/${comp_a_inst}* "${VARIABLES[$GRUPO]}"
				else
					cp ${dir}/${comp_a_inst}* "${VARIABLES[$BINDIR]}"
				fi
				COM_INSTALADOS[${!comp_a_inst}]="true"
				RETORNO="Comando \"${comp_a_inst}\" instalado correctamente."
			else
				RETORNO="Comando \"${comp_a_inst}\" ya se encuentra instalado."
				
			fi
		else
			RETORNO="Falta la carpeta de los ejecutables para instalar el comando \"${comp_a_inst}\"."
		fi
	
	
	elif [ -n "${ARCH_MAE_INSTALADOS[${!comp_a_inst}]}" ]; then
		if [ -d "${VARIABLES[$MAEDIR]}" ]; then
			if [ "${ARCH_MAE_INSTALADOS[${!comp_a_inst}]}" == false ]; then
				## Copiar el desde la fuente el archivo orignal a la carpeta de maestros
				cp ${dir}/${comp_a_inst}* "${VARIABLES[$MAEDIR]}"
				ARCH_MAE_INSTALADOS[${!comp_a_inst}]="true"
				RETORNO="Archivo \"${comp_a_inst}\" instalado correctamente."
			else
				RETORNO="Archivo \"${comp_a_inst}\" ya se encuentra instalado."
			fi
		else
			RETORNO="Falta la carpeta de archivos maestros para instalar \"${comp_a_inst}\"."
		fi
	else	
		RETORNO="Componente \"${com_a_inst}\" no existe dentro del sistema."
	fi
	
	mostrar_y_registrar "$RETORNO" -nm
	
	return 0
}

#######################################################################
##
##

function mostrar_dir_instalados {
	
	declare local var
	declare local nom_var	
	declare local grupo
	
	grupo="${VARIABLES[$GRUPO]}"
	
	
	
	for nom_var in "${!NOM_VARIABLES[@]}";do
	var="${VARIABLES[$nom_var]}"
		
		if [ $nom_var != $GRUPO ];then	
			if [ $nom_var == $BINDIR ] || [ $nom_var == $MAEDIR ] \
			|| [ $nom_var == $CONFDIR ]; then
			
				echo "-${DESCRIP_DIR_RES[$nom_var]}: ${grupo}/${var}"
				ls "$var"
			
			elif [ $nom_var == "$LOGDIR" ]; then
				echo "-${DESCRIP_DIR_RES[$nom_var]}: ${var}/<comando>.${VARIABLES[$LOGEXT]}"
			else
				if [ -n "${DESCRIP_DIR_RES[$nom_var]}" ];then
					echo "-${DESCRIP_DIR_RES[$nom_var]}: ${var}"
				fi
			fi
		fi
		
	done
	

	
	return 0
}

########################################################################
##
## Muestra cuales son los componente del sistema que se encuentra instalados
##

function mostrar_componentes_instalados {
	
	declare local est_inst
	declare local nom_comp
	declare local var
	
	mostrar_y_registrar "Se inicia el proceso de muestreo de componentes instalados." -nm
	
	if [ "$ESTADO_INSTALACION" == "C" ];then
		est_inst="COMPLETA"
		echo
		echo "Componentes Instalados:"
		mostrar_dir_instalados
		
	
	elif [ "$ESTADO_INSTALACION" == "P" ]; then
		est_inst="PARCIAL"
		echo
		echo "Componentes Instalados:"
		if [ "$DIR_INSTALADOS" == true ];then
			mostrar_dir_instalados
		fi
		
		## Se comienzan a listar los componentes faltantes
		echo
		echo "Componentes Faltantes: "
		
		for nom_comp in "${NOM_COM[@]}"; do
			if [ "${COM_INSTALADOS[${!nom_comp}]}" == "false" ]; then
				echo "-Comando: \"${nom_comp}\""
			fi
		done
		
		for nom_comp in "${ARCH_MAESTROS[@]}"; do
			if [ "${ARCH_MAE_INSTALADOS[${!nom_comp}]}" == "false" ]; then
				echo "-Archivo Maestro: \"${nom_comp}\""
			fi
		done
		
	elif [ "$ESTADO_INSTALACION" == "I" ]; then
		echo "No hay ningun componente Instalado"
		est_inst="INCOMPLETA"
	else
		est_inst="Error, no se puede determinar"
	fi
		
	echo
	
	mostrar_y_registrar "Estado de la Instalacion: $est_inst"
	
	echo

	mostrar_y_registrar "Se finaliza el proceso de muestreo de componentes instalados." -nm
	
	return 0
}

########################################################################
##
## Comprueba si la Instalacion del Sistema Esta Completa.
## RETORNO: true si esta completa, false en caso contrario
function verificar_estado_de_instalacion {

	declare local faltan_componentes=false
	declare local hay_componentes=false
	declare local var
	declare local i
	
	mostrar_y_registrar "Inicia comprobacion del estado del sistema." -nm
	
	for i in "${!NOM_COM[@]}";	do

		if [ "${COM_INSTALADOS[$i]}" == "false" ];then
			faltan_componentes=true
		elif [ "${COM_INSTALADOS[$i]}" == "true" ];then
			hay_componentes=true
		fi
	done
	
	
	for i in "${ARCH_MAESTROS[@]}"; do
	
		if [ "${ARCH_MAE_INSTALADOS[${!i}]}" == "false" ];then
			faltan_componentes=true
		elif [ "${ARCH_MAE_INSTALADOS[${!i}]}" == "true" ];then
			hay_componentes=true
		fi
	done
	
	
	if [ "$DIR_INSTALADOS" == true ]; then
		hay_componentes=true;
	fi
	
	if [ "$hay_componentes" == true ]; then
		if [ "$faltan_componentes" == true ];then
			ESTADO_INSTALACION="P"
		else
			ESTADO_INSTALACION="C"
		fi
	else
		if [ "$faltan_componentes" == true ];then
			ESTADO_INSTALACION="I"
		else
			ESTADO_INSTALACION="X"
		fi
	fi
	
	mostrar_y_registrar "Finaliza comprobacion del estado del sistema." -nm
	
	return 0
}

########################################################################
##
##
##

function comprobar_arch_de_instalacion {
	
	mostrar_y_registrar "Se inica la comprobacion de los archivos de instalacion." -nm
	
	if [ -f "$NOM_ARCH_DE_INSTALACION" ]; then
		if [ ! -d "$DIR_ARCH_DE_INSTALACION" ];then
			mkdir "$DIR_ARCH_DE_INSTALACION"
			echo "Se creo carpeta $DIR_ARCH_DE_INSTALACION"
		fi
		
		tar -xf "$NOM_ARCH_DE_INSTALACION" -C "$DIR_ARCH_DE_INSTALACION"
		chmod +x "$DIR_ARCH_DE_INSTALACION"/*

	else
		mostrar_y_registrar "Falta archivo de Instalacion \"${NOM_ARCH_DE_INSTALACION}\""
		finalizar_instalacion 2
	fi
	
	mostrar_y_registrar "Finaliza la comprobacion de los archivos de instalacion." -nm

	return 0
}

########################################################################
##
## Finaliza el script de instalacion, registrandolo en el log
##

function finalizar_instalacion {
	
	echo
	
	if [ "$1" != "0" ]; then
		mostrar_y_registrar "Instalacion Cancelada."
	else
		mostrar_y_registrar "Fin Instalacion."
	fi
	
	if [ -d "$DIR_ARCH_DE_INSTALACION" ]; then
		rm "${DIR_ARCH_DE_INSTALACION}/"*
		rmdir "${DIR_ARCH_DE_INSTALACION}"
	else
		echo "Error al eliminar carpeta de archivos de instalación: $DIR_ARCH_DE_INSTALACION"
	fi
	
	## Agrega los registros nuevos al registro de log
	if [ -f "$NOM_ARCH_LOG" ]; then
		if [ -f "${VARIABLES[$CONFDIR]}/$NOM_ARCH_LOG" ]; then
			cd "${VARIABLES[$CONFDIR]}"
			
			cat "$NOM_ARCH_LOG" ../"$NOM_ARCH_LOG" > aux
			mv aux "$NOM_ARCH_LOG"
			
			cd ..
			rm "$NOM_ARCH_LOG"
			
		else
			if [ -d "${VARIABLES[$CONFDIR]}" ]; then
				mv "$NOM_ARCH_LOG" "${VARIABLES[$CONFDIR]}"
			else
				rm "$NOM_ARCH_LOG"
			fi			
		fi		
	fi
	
	exit 0
}

function limpiar_pantalla {
	clear
	echo "TP SO7508 1er cuatrimetre 2012. Tema V, Derechos Reservados, Grupo 7"
	echo
	return 0
}

########################################################################
########################################################################
########################################################################
###								     ###
###		Cuerpo Principal del Script 			     ###
###								     ###
########################################################################
########################################################################
########################################################################

mostrar_y_registrar "Comando InstalaV5 Inicio de Ejecución"

limpiar_pantalla

comprobar_arch_de_instalacion

echo "Instalacion de Sistema V-FIVE"

buscar_archivo_config 

if [ -n "$RETORNO" ]; then	
	#########################################################
	## Se inicia la instalacion con otra ya hecha previamente
	#########################################################

	ruta_arch_config=$RETORNO
	
	
	cargar_configuracion "$ruta_arch_config"
	verificar_estado_de_instalacion
	mostrar_componentes_instalados
	verificar_perl_instalado
	

	if [ "$ESTADO_INSTALACION" != "C" ]; then

		if [ $# -eq 0 ]; then
			confirmar_respuesta "Faltan Componentes en el Sistema. ¿Instalar componentes faltantes?"

			if [ "$RETORNO" == "true" ];then
				limpiar_pantalla
				mostrar_y_registrar "Se confirmo reparacion del sistema." -nm

				reparar_sistema
			fi
		else
			
			confirmar_respuesta "¿Continuar con instalacion de Componentes Ingresados?"
			
			if [ "$RETORNO" == true ];then
				# Se instalaran los comandos argumento uno por uno
				mostrar_y_registrar "Se confirmo instalacion de componentes." -nm
				for COM in "$@"; do
					existe_componente "$COM"
					
					if [ "$RETORNO" == "true" ]; then
						echo
						confirmar_respuesta "¿Instalar Componente \"${COM}\"?"
						if [ "$RETORNO" == true ]; then
							instalar_componente "$COM"
						fi

						echo "$RETORNO"
					else
						mostrar_y_registrar "El componente \"$COM\" no es parte de sistema"
					fi
				done
			fi

		fi
	
		guardar_configuracion
		
		## ver porque no se guarda o recuparan bien los datos de los
		# archivos maestros
	
	elif [ "$ESTADO_INSTALACION" == "C" ]; then
		mostrar_y_registrar "El Sistema ya se encuentra instalado completamente"	
			
	else
		mostrar_y_registrar "Error en comprobacion de componentes del sistema"
	
	fi

else

	##################################################
	## Se incia el modo de instalacion desde cero
	##################################################


	verificar_perl_instalado
	CONFIRMACION=false
	
	echo
	echo "Defina los Directorios del Sistema."
	echo
	
	while [ "$CONFIRMACION" == false ]; do

		cagar_valores_defecto # Se almacenan los nombres por defecto de los directorios principales
	
		establecer_variables # Se establecen todos los nombres de carpetas y algunos datos importantes
		establecer_variables_num # Se establecen las variables de tipo numerico
		limpiar_pantalla
	
		mostrar_valores_ingresados
		
		confirmar_respuesta "Los datos ingresados son correctos?"
		CONFIRMACION=$RETORNO

	done
	
	
	
	if [ $# -eq 0 ]; then
		limpiar_pantalla
		confirmar_respuesta "Iniciando Instalacion. Esta Ud. seguro?"
		CONFIRMACION=$RETORNO
	

		if [ "$CONFIRMACION" == true ]; then
			limpiar_pantalla
			mostrar_y_registrar "Se confirmo la instacion del sistema." -nm
			instalar_sistema
			#guardar archivo Configuracion
		else
			finalizar_instalacion 1 ## Instalacion cancelada
		fi
	else
		limpiar_pantalla
		confirmar_respuesta "¿Continuar con Instalacion de Componentes Ingresados?"
		CONFIRMACION=$RETORNO
		
		# Se instalaran los comandos argumento uno por uno 
		if [ "$CONFIRMACION" == true ]; then
			mostrar_y_registrar "Se confirmo la instalacion de componentes." -nm
			crear_carpetas
			for COM in "$@"; do
			
				existe_componente "$COM"
				
				if [ "$RETORNO" == "true" ]; then
					echo
					confirmar_respuesta "¿Instalar Componente \"${COM}\"?"
					CONFIRMACION=$RETORNO
					
					if [ "$RETORNO" == true ];then
						mostrar_y_registrar "Se confirmo la instalacion del componente \"$COM\"." -nm
						instalar_componente "$COM"
						echo "$RETORNO"
					fi
				else
					mostrar_y_registrar "El componente \"$COM\" no es parte de sistema"
				fi
			done
		fi
		guardar_configuracion
	fi

fi


finalizar_instalacion 0
