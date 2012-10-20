#!/bin/bash


NOM_ARCH_INST="arch-sistema.dat"

NOM_SCR_INST="InstalaV5.sh"

NOM_SISTEMA="V5grupo07.tgz"

if [ $# -eq 0 ]; then
	
	nom_archivos_script=( InstalaV5.sh \
	 IniciarV5.sh \
	 DetectaV5.sh \
	 BuscarV5.sh \
	 ListarV5.pl \
	 MoverV5.sh \
	 LoguearV5.sh \
	 MirarV5.sh \
	 StopD.sh \
	 DetenerV5.sh \
	 StartD.sh)
	
	
	archivos_script=( src/InstalaV5/InstalaV5.sh \
	src/IniciarV5/IniciarV5.sh \
	 src/DetectaV5/DetectaV5.sh \
	 src/BuscarV5/BuscarV5.sh \
	 src/BuscarV5/ListarV5.pl \
	 src/MoverV5/MoverV5.sh \
	 src/LoguearV5/LoguearV5.sh \
	 src/MirarV5/MirarV5.sh \
	 src/StopD.sh \
	 src/DetenerV5.sh \
	 src/StartD.sh)
	 
	nom_archivos_maestros=(sistemas \
		patrones 
		ListaErrores)
	 
	archivos_maestros=( datos/sistemas \
		datos/patrones 
		src/LoguearV5/ListaErrores)
	


	for a in "${archivos_script[@]}";do
		cp $a .
	done

	for a in "${archivos_maestros[@]}";do
		cp $a .
	done

	tar -cf $NOM_ARCH_INST ${nom_archivos_script[@]} ${nom_archivos_maestros[@]}
	
	tar -z -cf $NOM_SISTEMA $NOM_ARCH_INST InstalaV5.sh
	
	echo "Creado archivo $NOM_SISTEMA."
	
	rm ${nom_archivos_script[@]} ${nom_archivos_maestros[@]}
	
	if [ -d grupo07 ]; then
		rm -r -f grupo07/
	fi
	mkdir grupo07
	mv "${NOM_SISTEMA}" grupo07
	cd grupo07; tar -xvf "${NOM_SISTEMA}"
	
else
	echo "NO se tiene que recibir argumentos."
fi
