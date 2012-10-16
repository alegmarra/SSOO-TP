INSTALACION

Insertar el dispositivo de almacenamiento co el contenido del trabajo práctico.

Crear en el directorio corriente un directorio de trabajo llamado grupo07.

Copiar el archivo *.tgz dentro del directorio grupo07.

Descomprimir el *.tgz, con el comando "tar -xvf *.tgz".

Correr el script InstalaV5.sh y seguir los pasos indicandos por el mismo.

Existen dos modos para llevar a cabo la instalacion del sistema V-FIVE:
-Completa
-Por componentes 

Para realizar una instalacion completa solo corra el script InstalaV5 normalmente.

Para llevar a cabo la instalacion por componentes se debe invocar al script del siguiente modo:

./InstalaV5.sh <nombre_componente1> <nombre_componente2> ...

Se pueden instalar mas de un componente de una sola vez solo indicando sus nombres.
Ej: ./InstalaV5.h IniciarV5 patrones

Se puede ir instalando componente por componente para hasta llegar a una instalacion completa del sistema, aunque solo en la primera instalacion por componentes se le pedira al usuario que defina los nombres de los directorios del sistema.

Para visualizar los componentes instalados se puede correr el script de instalacion nuevamente. Si el sistema esta completo
solo exhibira los componentes instalados y finalizara,en cambio hubiera alguno faltante le pedira al usuario si desea completar la instalacion.



