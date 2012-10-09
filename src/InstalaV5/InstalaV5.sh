###################################################################
## Script de Instalacion de Sistemas de Administracion de Logueo
##
###################################################################


#####################################################
# Declaracion y Definicion de Variables Principales #
#####################################################

NOM_ARCH_CONFIG="InstalaV5.conf"
NOM_ARCH_DE_INSTALACION="arch-sistema.dat"
NOM_DIR_ARCH_DE_INSTALACION="arch_instalcion"

NOM_VARIABLES=(GRUPO CONFDIR BINDIR MAEDIR ARRIDIR ACEPDIR RECHDIR PROCDIR REPODIR LOGDIR LOGEXT LOGSIZE 
DATASIZE SECUENCIA1 SECUENCIA2)

declare -A DESCRIP_DIR=( ["CONFDIR"]="Directorio donde se encuentras los archivos de Configuracion del Sistema" \
	["BINDIR"]="directorio de archivos ejecutables" \
	["MAEDIR"]="directorio de archivos Maestros" \
	["ARRIDIR"]="directorio de arribo de archivos externos" \
	["ACEPDIR"]="directorio de grabacion de archivos rechazados" \
	["RECHDIR"]="directorio de grabacion de los archivos externos aceptados" \
	["PROCDIR"]="directorio de grabacion de los archivos procesados" \
	["REPODIR"]="directorio de grabacion de los reportes de salida" \
	["LOGDIR"]="directorio de grabacion de los logs del sistema" \
	)

declare -A VARIABLES=( ["BINDIR"]="grupo07" ["CONFDIR"]="config" )

# poner los faltantes
NOM_COM=(IniciarV5 DetectaV5 BuscarV5 ListarV5 MoverV5 LoguearV5 MirarV5 StopD StartD)
COM_INSTALADOS=( ["${NOM_COM[0]}"]=false ["${NOM_COM[1]}"]=false ["${NOM_COM[2]}"]=false ["${NOM_COM[3]}"]=false \
	["${NOM_COM[3]}"]=false ["${NOM_COM[4]}"]=false ["${NOM_COM[5]}"]=false ["${NOM_COM[6]}"]=false \
	["${NOM_COM[7]}"]=false ["${NOM_COM[8]}"]=false)

ARCH_MAESTROS=( patrones sistemas )
ARCH_MAE_INSTALADOS=( ["${ARCH_MAESTROS[0]}"]=false ["${ARCH_MAESTROS[1]}"]=false )
RETORNO=""


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
	if [ "$2" == "0" ]; then
		echo $1
	fi
	return 0
}

##########################################################################
##
## Funcion que almacena el string parametro en el archivo de log y lo
## muesta en pantalla
## Arg0: Mensaje a procesar en el "log"

function mostrar_y_registrar {
	declare local msj=$1
	
	echo "$msj"
	#...
	#...

	return 0
}

##########################################################################

##
## Busca un archivo en todos los subdirectorios partir del actual, si no lo encuentra retorna un string nulo
## Arg0: nombre del archivo a buscar
## RETORNO: ruta completa del archivo encontrado, desde el directorio actual.

function buscar_archivo {

declare local a_buscar=$1


find > aux.out

grep ".*${a_buscar}$" aux.out > aux-2.out  


read RETORNO < aux-2.out

rm aux.out
rm aux-2.out

return 0

}

############################################################################
##
## Funcion que crea las carpetas del sistema

function crear_carpetas {
	declare nom_var
	declare local nom_dir
		
	for nom_var in "${NOM_VARIABLES[@]}";do
	
		if [ -n  "${DESCRIP_DIR[$nom_var]}" ]; then
			nom_dir="${VARIABLES[$nom_var]}"
			if [ -d "$nom_dir" ]; then
				:
			else
				mkdir "$nom_dir"
			fi

		fi

	done

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
	
	if [ -z $nom_dir ]
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
	declare local aux
	pwd > ruta
	read aux < ruta
	rm ruta
	
	VARIABLES["GRUPO"]="$aux"
	VARIABLES["CONFDIR"]="conf"
	VARIABLES["BINDIR"]="bin"
	VARIABLES["MAEDIR"]="mae"
	VARIABLES["ARRIDIR"]="arribos"
	VARIABLES["ACEPDIR"]="aceptados"
	VARIABLES["RECHDIR"]="rechazados"
	VARIABLES["PROCDIR"]="procesados"
	VARIABLES["REPODIR"]="reportes"
	VARIABLES["LOGDIR"]="log"

	VARIABLES["LOGEXT"]="log"
	VARIABLES["LOGSIZE"]=100
	VARIABLES["DATASIZE"]=150

	VARIABLES["SECUENCIA1"]=0
	VARIABLES["SECUENCIA2"]=0
	
	return 0
}


#########################################################################
##
## Muestra los valores de las variables actuales para los directorios
## 
function mostrar_nombres_dir {
	declare local nom_var=""
	declare local decripcion=""
	for nom_var in "${NOM_VARIABLES[@]}"; do
		
		descripcion="${DESCRIP_DIR[$nom_var]}"
		

		if [ -n "$descripcion" ]; then
			echo "${descripcion}: "${VARIABLES[$nom_var]}
		fi

	done

	

}

################################################################
##
## Guarda la configuracion del sistema

function guardar_configuracion {
	declare local var
	declare local fecha_creacion
	declare local registro
	date > fecha
	read fecha_creacion < fecha
	rm fecha
	
	if [ -d "${VARIABLES[CONFDIR]}" ]; then
	
		cd "${VARIABLES[CONFDIR]}"
		
		registro="GRUPO"="${VARIABLES[GRUPO]}"="$USERNAME"="${fecha_creacion}"
		
		echo "$registro" > "$NOM_ARCH_CONFIG"

		for var in "${NOM_VARIABLES[@]}"; do
		
			if [ "$var" != "GRUPO" ]; then
				registro="${var}=${VARIABLES[GRUPO]}/${VARIABLES[$var]}=$USERNAME=${fecha_creacion}"
				echo "$registro" >> "$NOM_ARCH_CONFIG"
			fi		

		done

		for var in "${NOM_COM[@]}"; do
			if [ "$COM_INSTALADOS[$var]" == true ]; then
				registro="COMANDO=${var}=INSTALADO=$fecha_creacion"
				echo "$registro" >> "$NOM_ARCH_CONFIG"
			fi

		done

		
		for var in "${ARCH_MAESTROS[@]}"; do
			if [ "$ARCH_MAE_INSTALADOS[$var]" == true ]; then
				registro="ARCHIVO=${var}=INSTALADO=$fecha_creacion"
				echo "$registro" >> "$NOM_ARCH_CONFIG"
			fi

		done

	else
		echo "Error al guardar configuracion: No existe carpeta de configuracion"
	fi
	return 0
}

#########################################################################

##
## Carga las variables principales del Sistema
## Arg0: ruta del archivo de configuracion
##
function cargar_configuracion {
	
	echo_depuracion "Se estan por cargar las variables" 0

	declare local ruta_arch=$1
	declare local nom_var
	declare local dir_instalado

	declare local nom_com
	declare local com_instalado

	declare local nom_arch
	declare local arch_instalado
	
	if [ -f "$ruta_arch" ]; then
	
		for nom_var in "${NOM_VARIABLES[@]}"; do
			grep "^${nom_var}.*" "$ruta_arch" > aux
			cut -d "=" -f 2 aux > aux2
			read dir_instalado < aux2

			if [ "$nom_var" == "GRUPO" ]; then
				VARIABLES["GRUPO"]="${dir_instalado}"
			else
				VARIABLES["$nom_var"]="${dir_instalado##*/}"
				echo_depuracion "Variable: $nom_var = ${VARIABLES[$nom_var]}" 0
			fi
		done
		
	
		grep "^COMANDO=.*" "$ruta_arch" > comandos.dat

		for nom_com in "${NOM_COMANDOS[@]}"; do
			grep ".*=${nom_com}=.*" comandos.dat > aux
			cut -d "=" -f 3 aux > aux2
			read com_instalado < aux2

			if [ "${com_instalado}" == "INSTALADO" ]; then
				COM_INSTALADOS[${nom_com}]=true
			else
				COM_INSTALADOS[${nom_com}]=false
			fi
		done
	

		grep "^ARCHIVO.*" "$ruta_arch" > archivos.dat

		for nom_arch in "${ARCH_MAESTROS[@]}"; do
			grep ".*=${nom_arch}=.*" archivos.dat > aux
			cut -d "=" -f 3 aux > aux2
			read arch_instalado < aux2

			if [ "${arch_instalado}" == "INSTALADO" ]; then
				ARCH_MAE_INSTALADOS[${nom_arch}]=true
			fi
		done
				
		
		rm comandos.dat
		rm archivos.dat		
		rm aux
		rm aux2

	else
		echo_depuracion "Archivo de configuracion no existe" 0
		return 1
	fi
}

########################################################################
##
## Funcion que carga los nombre de las variables
## 

function establecer_variables {
	declare local mensaje=""	

	for nom_var in "${NOM_VARIABLES[@]}"; do

		echo_depuracion "$nom_var"
		echo_depuracion "${DESCRIP_DIR[$nom_var]}"

		mensaje=${DESCRIP_DIR[$nom_var]}
		
		if [ -n "${mensaje}" ] && [ "$nom_var" != "LOGDIR" ]; then
			
			mensaje="Definir el "${mensaje}
				
			leer_entrada "$mensaje" "${VARIABLES[$nom_var]}"
			VARIABLES[$nom_var]=$RETORNO

		fi
	done;
	

	return 0
}

#########################################################################
##
## Funcion que pregunta por los datos numericos configurables del sistema
##

function establecer_variables_num {
	
	declare local msj=""	
	declare local espacio_suficiente=false
	declare local valor

	msj="Define el tamanio maximo para los archivos de log"

	while [ "$espacio_suficiente" == false ]; do

		leer_entrada "$msj" "$LOGSIZE"
		valor=$RETORNO

		# Comprobar espacio
		# Si es hay suficiente espacio terminar ciclo
		# 
		espacio_suficiente=true
		VARIABLES["LOGSIZE"]=$valor		

	done
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
	msj="${1} (S/N)"
	
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
			echo "Respuesta incorrecta, vuelva a ingresarla"
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

	which perl > ruta
	
	if [ $? -eq 0 ]; then

		RETORNO=true
	else
		RETORNO=false
		echo "Perl no se encuentra instalado. Se nesecista tener Perl 5 o superior"
	fi	

	rm ruta	

	return 0
}



################################################################
##
## Instala componentes del sistema
##

function instalar_sistema {
	
	declare local comp_a_inst

	echo "Creando Directorios..."
	crear_carpetas
	
	echo "Creando Ejecutables..."
	for comp_a_inst in "${NOM_COM[@]}"; do
		instalar_componente "$comp_a_inst"
		# imprimir y logeuar
	done
	
	echo "Creando Archivos..."
	for comp_a_inst in "${ARCH_MAESTROS[@]}"; do
		instalar_componente "$comp_a_inst"
		# imprimir y loguear

	done
	
	guardar_configuracion

	return 0
}


########################################################################
## Repara los componentes faltantes en el sistema
## 

function reparar_sistema {

	declare local com
	declare local arch	

	for com in "${NOM_COM[@]}"; do
		
		if [ "${COM_INSTALADOS[$com]}" == false ]; then
			instalar_componente "$com"
			# loguear componente instalado
			COM_INSTALADOS["$com"]=true
		fi

	done

	for arch in "${ARCH_MAESTROS[@]}"; do
	
		if [ "${ARCH_MAE_INSTALADOS[$com]}" == false ]; then
			instalar_componente "$arch"
			#loguear archivo instalado
			ARCH_MAR_INSTALADOS["$arch"]=true
		fi
		
	done

	return 0
}

########################################################################
## Instala el componente pasado como argumento que puede un comando o
## un archivo.
## Arg0: nombre del componente a instalar
## RETORNO: string con una descripcion del proceso del instalacion

function instalar_componente {
	declare local comp_a_inst=$1

	if [ -n "${COM_INSTALADOS[$comp_a_inst]}" ]; then
		if [ -d "${VARIABLES[BINDIR]}" ]; then
			## Copiar el desde la fuente el archivo orignal a la carpeta de maestros
			RETORNO="Comando \"${comp_a_inst}\" instalado correctamente."
		else
			RETORNO="Falta la carpeta de los ejecutables para instalar el comando \"${comp_a_inst}\"."
		fi

	elif [ -n "${ARCH_MAE_INSTALADOS[$comp_a_inst]}" ]; then
		if [ -d "${VARIABLES[MAEDIR]}" ]; then
			## Copiar el desde la fuente el archivo orignal a la carpeta de maestros
			RETORNO="Archivo \"${comp_a_inst}\" instalado correctamente."
		else
			RETORNO="Falta la carpeta de archivos maestros para instalar \"${comp_a_inst}\"."
		fi
	else	
		RETORNO="Componente \"${com_a_inst}\" no existe dentro del sistema."
	fi

	
	return 0
}


########################################################################
##
## Muestra cuales son los componente del sistema que se encuentra instalados
##

function mostrar_componentes_instalados {

	return 0
}

########################################################################
##
## Comprueba si la Instalacion del Sistema Esta Completa.
## RETORNO: true si esta completa, false en caso contrario
function verificar_instalacion_completa {

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


echo "Instalacion de Sistema V-FIVE"

buscar_archivo "$NOM_ARCH_CONFIG"

if [ -z "$RETORNO" ]; then	

	echo_depuracion "Se entro en la instalcion normal"	

	CONFIRMACION=false
	
	while [ "$CONFIRMACION" == false ]; do


		cagar_valores_defecto # Se almacenan los nombres por defecto de los directorios principales
	
		establecer_variables # Se establecen todos los nombres de carpetas y algunos datos importantes
		establecer_variables_num # Se establecen las variables de tipo numerico
		clear
	
		mostrar_nombres_dir
		
		confirmar_respuesta "Conservar estos valores"
		CONFIRMACION=$RETORNO

	done
	
	if [ $# -eq 0 ]; then

		confirmar_respuesta "Instalar Sistema"
		CONFIRMACION=$RETORNO
	

		if [ "$CONFIRMACION" == true ]; then
			instalar_sistema
			#guardar archivo Configuracion
			echo "Instalacion realizada exitosamente"
		else
			echo "Instalacion Cancelada"
		fi
	else
		confirmar_respuesta "Instalar Componentes(${@})?"
		CONFIRMACION=$RETORNO
		# Se instalaran los comandos argumento uno por uno
		crear_carpetas 
		if [ "$CONFIRMACION" == true ]; then
			for COM in "$@"; do
				instalar_componente "$COM"
				echo "$RETORNO"
			done
		fi
	fi

else

	ruta_arch_config=$RETORNO
	
	cargar_configuracion "$ruta_arch_config"
	mostrar_componentes_instalados
	verificar_instalacion_completa
	INST_COMPLETA=$RETORNO

	if [ "$INST_COMPLETA" == false ]; then

		if [ $# -eq 0 ]; then
			confirmar_respuesta "Faltan Componentes en el Sistema. ¿Instalar componentes faltantes?"
			REPARAR=$RETORNO
	
			reparar_sistema
		else
			
			# Se instalaran los comandos argumento uno por uno
			for COM in "$@"; do
				instalar_componente "$COM"
				echo "$RETORNO"
			done

		fi
		
	else
		echo "El Sistema ya se encuentra instalado completamente"	
	fi

fi



# echo "Fin de Instalacion"
# echo "FIN"

#exit 0
