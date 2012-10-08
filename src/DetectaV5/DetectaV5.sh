#!/bin/bash

validarFormato () {

	if [[ ${1##*/} =~ [[:alnum:]+]_[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]
	then
		return 0
	else 
		return 1 
	fi
}


validarSIS_ID () {

	id=${1##*/}

	num=`grep "^${id%_*};[^;]\+;[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\};*" ${MAEDIR}/sistemas | wc -l`

	if [[ $num  -gt 0 ]];then
		return 0
	else
		return 1
	fi

}

validarFecha () {

	local file=${1##*/}

	id=${file%_*}
	fecha=${file#*_}
	
	# Si cumple el formato de fecha (@TODO mejorar validacion)
	if [[ ${fecha} =~ ^[12][09][0-9]+-[01][0-9]-[0-3][0-9]$ ]]
	then
		
		fecha=${fecha//-/}
	
		# Si es una fecha menor al dia de hoy
		if [[ ${fecha} -le `date +"%Y%m%d"` ]]
		then

			reg=`grep "^${id%_*};[^;]\+;[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\};*" ${MAEDIR}/sistemas`
			
			regFechas=${reg#*;*;}
			inicio=${regFechas%;*}
			fin=${regFechas#*;}

			# Si es mayor a la fecha de inicio del sistema
			if [[ ${fecha} -ge ${inicio//-/} ]]; 
			then
				if [[ ! -z "$fin" ]]; 
				then
					# Si es menor a la fecha de fin del sistema
					if [[ ${fecha} -le ${fin//-/} ]]; 
					then 
						return 0
					else
						return 1
					fi
				else
					return 0
				fi
			fi
		fi
	fi

	return 1

}

# @TODO Check si ENTORNO INICIALIZADO

# Coloco paths DE PRUEBA, @TODO usar el path correcto
ARRDIR="./tests/arribos"
MAEDIR="./tests/maestros"
RECHDIR="./tests/rechazados"
ACEPDIR="./tests/aceptados"

#@TODO manejo de path a otros script externos

pName="DetectaV5.sh"
pID=`ps -C "$pName" -o "pid="`

if [[ $? -eq 1 ]]; then
	#@TODO Log de error
	echo "Ya existe otro proceso en ejecucion"
	exit 1
fi

arribos=`find "$ARRDIR" -maxdepth 1 -type f -regex ${ARRDIR%/}"/.*" | wc -l`

if [[ $arribos -gt 0 ]]; then

	for file in `find "$ARRDIR" -maxdepth 1 -type f -regex ${ARRDIR%/}"/.*"`
	do	
		validarFormato "$file"
		if [[ "$?" -eq 0  ]];then
			
			validarSIS_ID "$file"
			if [[ "$?" -eq 0  ]]; then

				validarFecha "$file"
				if [[ "$?" -eq 0  ]]; then
					
					../MoverV5/moverV5.sh "$file" "$ACEPDIR"
					# @TODO log de exito			

				else
				# Fecha invalida
					../MoverV5/moverV5.sh "$file" "$RECHDIR"
					#@TODO log de rechazo
				fi
		
			else
			# SIS_ID invalido
				../MoverV5/moverV5.sh "$file" "$RECHDIR"
				#@TODO log de rechazo
			fi
		else
		# Formato invalido
			../MoverV5/moverV5.sh "$file" "$RECHDIR"
			#@TODO log de rechazo
		fi
	done
fi

