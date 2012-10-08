#!/usr/bin/perl -w
use Getopt::Long;

# configuro el módulo de Getopt para que no imprima errores en caso de opciones no validas
# ya que eso lo manejo manualmente, y para que no acepte abreviaciones
# @see http://perldoc.perl.org/Getopt/Long.html
Getopt::Long::Configure('pass_through', 'no_auto_abbrev');

# define las opciones validas
%opciones = ('global', 1);
GetOptions( \%opciones, 'ayuda|help|h|?', 'global|g', 'resultado|r', 'salida|x');

# validao opciones de comand line
if (@ARGV > 0 or defined $opciones{ayuda}) {
	usage();
}

# función de ayuda
sub usage
{
	if (@ARGV > 0) {
		print "Parametros desconocidos: " . join(' ', @ARGV) . "\n";
	}
	print "\nUso: ListarV5 [opciones]\n";
	printf "\t%-20s (default) Consultar los resultados globales.\n", "-g, -global";
	printf "\t%-20s Consultar los resultados detallados.\n\t%20s Implica no global.\n", "-r, -resultado", " ";
	printf "\t%-20s Grabar el informe en un archivo en lugar de\n\t%20s imprimirlo en pantalla.\n", "-x, -salida", " ";
	exit;
}

system 'clear';

if (opendir(DIRH, $ENV{'PROCDIR'})) {
	@flist = readdir(DIRH);
	closedir(DIRH);
}

if ($opciones{resultado}) {
	%patterns = ();
	%ciclos = ();
	%archivos = ();
	foreach (@flist) {
		# ignorar . y .. :
		next if ($_ eq "." || $_ eq "..");
		if ($_  =~ /resultados.([0-9]+)/) {
			$patterns{$1} = 1;
			open (RESULTADO,"<$ENV{'PROCDIR'}/$_") || die "ERROR: No puedo abrir el fichero $ENV{'PROCDIR'}/$_\n";
			while ($linea = <RESULTADO>) {
				@data = split('\+-#-\+', $linea);
				$ciclos{@data[0]} = 1;
				$archivos{@data[1]} = 1;
			}
		}
	}

	sort keys %archivos;
	sort keys %ciclos;
	print join(", ", %patterns) . "\n";
	print join(", ", %ciclos) . "\n";
	print join(", ", %archivos) . "\n";
	
}
else {

}
