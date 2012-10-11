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

# 
# Tomando un hash como parametro (valor), del a forma %hash -> {key: 0 or 1},
# Devuelve un string de los seleccionados o "Todos" si están todos seleccionados
#
sub str_seleccion {
	my %hash = @_;
	my @selected = sort grep { $hash{$_} == 1} keys %hash;
	return ((eval(join('*', values %hash)) =~ /^1$/) or (eval(join('+', values %hash)) =~ /^0$/)) ? 'Todos' : join(', ', @selected);
}

# 
# Tomando un hash como parametro (referencia), del a forma %hash -> {key: 0 or 1},
# Construye un menu de selección poniendo alternando entre 1 y 0 para seleccionado o no.
#
sub hash_selection {
	my $hashref = shift;
	@keys = sort keys $hashref;
	my $finish = 0;
	while( ! $finish ) {
		system 'clear';
		my $i = 1;
		foreach my $key ( @keys ) {
		  	print(($hashref->{$key} == 1 ? '*' : ' ') . " $i: $key\n");
		  	$i++;		  
		}

	    print "\nx: Volver atras\n";
	    print "\nSeleccione alguna de los siguientes opciones: ";
	    my $opcion = <STDIN>;
	    chomp($opcion);
		if ($opcion =~ /^x$/) {
	    	$finish = 1;
	    }
		if ($opcion =~ /^(\d)$/) {
			if ($opcion > 0 and defined $keys[$opcion-1]) {
	    		$hashref->{$keys[$opcion-1]} = $hashref->{$keys[$opcion-1]} ? 0 : 1;
	    	}
	    }
    }

}

# Abro el archivo maestro de patrones\
%patterns_def = ();
open(PATRONES, "<$ENV{'MAEDIR'}/patrones") or die "No puede abrir el archivo de patrones";
while ($linea = <PATRONES>) {
	$linea =~ /(\d),'(.*)',/;
	$patterns_def{$1} = $2;
}

# Abro el directorio de procesados
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
			$patterns{$patterns_def{$1}} = 0;
			open (RESULTADO,"<$ENV{'PROCDIR'}/$_") || die "ERROR: No puedo abrir el fichero $ENV{'PROCDIR'}/$_\n";
			while ($linea = <RESULTADO>) {
				@data = split('\+-#-\+', $linea);
				$ciclos{$data[0]} = 0;
				$archivos{$data[1]} = 0;
			}
		}
	}

	print join(", ", %patterns) . "\n";
	print join(", ", %ciclos) . "\n";
	print join(", ", %archivos) . "\n";

	my $finish = 0;
	while( ! $finish ) {
		system 'clear';
	    print "1: Patrones: " . str_seleccion(%patterns) . "\n";
	    print "2: Ciclos: " . str_seleccion(%ciclos) . "\n";
	    print "3: Archivos: " . str_seleccion(%archivos) . "\n";
	    print "\ni: Imprimir informe\n";
	    print "x: Salir\n";
	    print "\nSeleccione alguno de los siguientes filtros o comandos: ";
	    my $opcion = <STDIN>;
	    chomp($opcion);
		if ($opcion =~ /^x$/) {
	    	$finish = 1;
	    }
		if ($opcion =~ /^1$/) {
	    	hash_selection(\%patterns);
	    }
		if ($opcion =~ /^2$/) {
	    	hash_selection(\%ciclos);
	    }
		if ($opcion =~ /^3$/) {
	    	hash_selection(\%archivos);
	    }
    }
	

}
else {

}
