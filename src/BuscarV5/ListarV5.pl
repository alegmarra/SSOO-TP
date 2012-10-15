#!/usr/bin/perl -w
use Getopt::Long;
use Term::ANSIColor;

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
	return 'Todos' if eval(join('*', values %hash)) =~ /^1$/;
	return 'Ninguno' if hash_vacio(%hash);
	return join(', ', @selected);
}

#
# Tomando un hash como parametro, de la forma %hash -> {key: 0 or 1},
# Devuelve 1 si todos los elementos del hash son 0, o 0 en caso contrario
#
sub hash_vacio {
	my %hash = @_;
	return (eval(join('+', values %hash)) =~ /^0$/ ? 1 : 0);
}

#
# Tomando un hash como parametro (referencia), de la forma %hash -> {key: 0 or 1},
# Construye un menu de selección poniendo alternando entre 1 y 0 para seleccionado o no.
#
sub hash_selection {
	my $hashref = shift;
	@keys = sort keys $hashref;
	my $finish = 0;
	while( ! $finish ) {
		print "\n";
		my $i = 1;
		foreach my $key ( @keys ) {
		  	print(($hashref->{$key} == 1 ? '*' : ' ') . " $i: $key\n");
		  	$i++;
		}
	    print "\nn: Seleccionar ninguna\n";
	    print "t: Seleccionar todas\n";
	    print "x: Volver atras\n";
	    print "\nSeleccione alguna de los siguientes opciones: ";
	    my $opcion = <STDIN>;
	    chomp($opcion);
		if ($opcion =~ /^x$/) {
	    	$finish = 1;
	    }
		if ($opcion =~ /^t$/) {
	    	foreach (keys $hashref) {
	    		$hashref->{$_} = 1;
	    	}
	    }
		if ($opcion =~ /^n$/) {
	    	foreach (keys $hashref) {
	    		$hashref->{$_} = 0;
	    	}
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
%patterns_keys = ();
open(PATRONES, "<$ENV{'MAEDIR'}/patrones") or die "No puede abrir el archivo de patrones";
while ($linea = <PATRONES>) {
	$linea =~ /(\d),'(.*)',/;
	$patterns_def{$1} = $2;
	$patterns_keys{$2} = $1;
}

# Abro el directorio de procesados
if (opendir(DIRH, $ENV{'PROCDIR'})) {
	@flist = readdir(DIRH);
	closedir(DIRH);
}

#
# proceso la opción resultado
#
if ( $opciones{resultado} ) {
	%patterns = ();
	%ciclos = ();
	%archivos = ();
	foreach (@flist) {
		# ignorar . y .. :
		next if ($_ eq "." || $_ eq "..");
		if ($_  =~ /resultados.([0-9]+)/) {
			$patterns{$patterns_def{$1}} = 1;
			open (RESULTADO,"<$ENV{'PROCDIR'}/$_") || die "ERROR: No puedo abrir el fichero $ENV{'PROCDIR'}/$_\n";
			while ($linea = <RESULTADO>) {
				@data = split('\+-#-\+', $linea);
				$ciclos{$data[0]} = 1;
				$archivos{$data[1]} = 1;
			}
			close(RESULTADO);
		}
	}

	my $finish = 0;
	while( ! $finish ) {
	    print "\n1: Patrones: " . str_seleccion(%patterns) . "\n";
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
		if ($opcion =~ /^i$/) {
			if ( hash_vacio(%patterns) or hash_vacio(%ciclos) or hash_vacio(%archivos) ) {
				print color 'bright_red' ;
				print "\nDebe seleccionar al menos un patrón, un ciclo y un archivo para poder realizar\nla consulta.\n";
				print color 'reset';
				next;
			}
			$salida = *STDOUT;
			if ($opciones{salida}) {
				($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime;
				$year+=1900;
				$mon++;
				$archivo = sprintf("salida_%4d%02d%02d%02d%02d%02d", $year, $mon, $mday, $hour, $min, $sec);
				open( SALIDA, ">$ENV{'REPODIR'}/$archivo" ) || die "ERROR: No puedo abrir el fichero $ENV{'REPODIR'}/$archivo\n";
				$salida = SALIDA;
			}
			foreach ( sort keys %patterns ) {
				if ($patterns{$_}) {
					print $salida "\nPatrón: $_\n";
					print $salida "Ciclos: " . str_seleccion(%ciclos) . "\n";
					print $salida "Archivos: " . str_seleccion(%archivos) . "\n\n";
					open( RESULTADO, "<$ENV{'PROCDIR'}/resultados.$patterns_keys{$_}" ) || die "ERROR: No puedo abrir el fichero $ENV{'PROCDIR'}/resultados.$patterns_keys{$_}\n";
					$count = 0;
					while ($linea = <RESULTADO>) {
						@data = split('\+-#-\+', $linea);
						if ( $ciclos{$data[0]} and $archivos{$data[1]} ) {
							printf $salida "%-10s%-25s %s", $data[0], $data[1], $data[3];
							$count++;
						}
					}
					if (!$count) {
						print $salida "No se encontraon resultados para este patrón con los filtros seleccionados.\n";
					}
					else {
						print $salida "\nTotal de resultados para este patrón con los filtros seleccionados.: $count\n";
					}

					close (RESULTADO);
				}
				$finish = 1;
			}
		}
    }
}
