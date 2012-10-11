
NOM_ARCH_INST="arch-sistema.dat"



if [ $# -eq 0 ]; then
	archivos_script=(IniciarV5 DetectaV5 BuscarV5 ListarV5 MoverV5 LoguearV5 MirarV5 StopD StartD)
	archivos_maestros=(sistemas patrones)

	for i in "${archivos_script[@]}";do
		echo "Archivo de script de prueba para $i" > $i
	done

	for i in "${archivos_maestros[@]}";do
		echo "Archivo maestro de prueba para $i" > $i
	done

	tar -cf $NOM_ARCH_INST ${archivos_script[*]} ${archivos_maestros[*]}

	rm ${archivos_script[*]} ${archivos_maestros[*]}
else
	tar -cf $NOM_ARCH_INST $@
	echo "Se creo el archivo $NOM_ARCH_INST con los archivos $@"
fi
