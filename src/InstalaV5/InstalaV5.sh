###################################################################
## Script de Instalacion de Sistemas de Administracion de Logueo
##
###################################################################


####################################################
# Declaracion y Definicion de Variables Principales
####################################################


NOM_VARIABLES=(GRUPO CONFDIR BINDIR MAEDIR ARRIDIR ACEPDIR RECHDIR PROCDIR REPODIR LOGDIR LOGEXT LOGSIZE 
DATASIZE SECUENCIA1 SECUENCIA2)

declare -A DESCRIP_DIR=( ["CONFDIR"]="Directorio donde se encuentras los archivos de Configuracion del Sistema" \
	["BINDIR"]="Directorio donde se encuentran los ejectubles del Sistema" \
	["ACEPDIR"]="Directorio donde se encuentran los archivos aceptados" \
	)

declare -A VARIABLES=( ["BINDIR"]="grupo07" ["CONFDIR"]="config" )

# poner los faltantes
NOM_COMANDOS=(MirarV5 BuscarV5 IniciarV5)

RETORNO=""


########################################################################
########################################################################
##								      ##
##		Definicion de funciones utilizadas		      ##
##								      ##
########################################################################
########################################################################

###########################
# Funcion de echo para modo de Depuracion
function echo_depuracion {
	echo $1
	return 0
}

######################################################

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

# Solicitar ingreso de directorio
# Arg0 : Mensaje descripcion del directorio
# Arg1 : Nombre del directorio por defecto

function leer_nombre_dir {

	declare local nom_dir;

	echo "${1}(${2}):"; 
	read nom_dir;
	
	if [ -z $nom_dir ]
	then	
		#echo "Es nulo lo ingresado"
		nom_dir=$2;
	fi

	#echo "$nom_dir" > $retorno
	#cat $retorno
	RETORNO=$nom_dir	

	return 0
}
#####################################################################
##
## Carga los valores por defecto de la variable de ambiente
##

function cagar_valores_defecto {

	
	VARIABLES[CONFDIR]="conf"
	VARIABLES[BINDIR]="bin"
	VARIABLES[MAEDIR]="mae"
	VARIABLES[ARRDIR]="arribos"
	VARIABLES[ACEPDIR]="aceptados"
	VARIABLES[RECHDIR]="rechazados"
	VARIABLES[PROCDIR]="procesados"
	# REPODIR="."
	LOGDIR="logdir"
	LOGEXT="log"

	VARIABLES[LOGSIZE]=100
	VARIABLES[DATASIZE]=150
	


	return 0
}


############################################################################

##
## Carga las variables principales del Sistema
## Arg0: ruta del archivo de configuracion
##
function cargar_configuracion {
	
	declare local ruta_arch=$1
	
	if [ -f ruta_arch ]; then
	
		for nom_var in "${NOM_VARIABLES[@]}"; do
			grep "^${nom_var}.*" "$ruta_arch" > aux
			cut -d "=" -f 2 aux > aux2
			read ${nom_var} < aux2
		done

		rm aux
		rm aux2
		

		return 0
	
		for nom_com in "${NOM_COMANDOS[@]}"; do
			grep "^${nom_com}.*" "$ruta_arch" > aux
			cut -d "=" -f 1 aux > aux2
			read com_instalado < aux2

			if [ "${com_instalado}" == "INSTALADO" ]; then
				COM_INSTALADOS[${nom_com}]=true
			else
				COM_INSTALADOS[${nom_com}]=false
			fi
		done	
		
		rm aux
		rm aux2

	else
		return 1
	fi
}

########################################################################

##
## Funcion que carga los nombre de las variables
## 

function establecer_variables {
	
	for nom_var in "${NOM_VARIABLES[@]}"; do

		echo_depuracion "$nom_var"
		echo_depuracion "${DESCRIP_DIR[$nom_var]}"

		mensaje=${DESCRIP_DIR[$nom_var]}
		
		if [ ${#mensaje} -gt 0 ]; then
			
			mensaje="Definir la capeta $nom_var "${mensaje}
				
			leer_nombre_dir "$mensaje" "${VARIABLES[$nom_var]}"
			VARIABLES[$nom_var]=$RETORNO

		fi
	done;

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

nom_arch_config="Instala.conf"

echo "Instalacion de Sistema V-FIVE"

buscar_archivo "$nom_arch_config"

if [ -z "$RETORNO" ]; then	
	
	echo_depuracion "Se entro en la instalacion normal"	
	
	cagar_valores_defecto
	
	establecer_variables
	# ...
	# ...
	

else

	ruta_arch_config=$RETORNO
	
	cargar_configuracion "$ruta_arch_config"

	# ...
	# ...
fi

