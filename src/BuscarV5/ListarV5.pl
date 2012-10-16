#!/usr/bin/perl
use Getopt::Long;
use Term::ANSIColor;
use Data::Dumper;

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
	@keys = sort keys %$hashref;
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
	    print "\nSeleccione alguna de los siguientes opciones (acepta rangos x-y): ";
	    my $opcion = <STDIN>;
	    chomp($opcion);
		if ($opcion =~ /^x$/) {
	    	$finish = 1;
	    }
		if ($opcion =~ /^t$/) {
	    	foreach (keys %$hashref) {
	    		$hashref->{$_} = 1;
	    	}
	    }
		if ($opcion =~ /^n$/) {
	    	foreach (keys %$hashref) {
	    		$hashref->{$_} = 0;
	    	}
	    }
		if ($opcion =~ /^(\d+)$/) {
			if ($opcion > 0 and defined $keys[$opcion-1]) {
	    		$hashref->{$keys[$opcion-1]} = $hashref->{$keys[$opcion-1]} ? 0 : 1;
	    	}
	    }
		if ($opcion =~ /^(\d+)-(\d+)$/) {
			foreach ($1..$2) {
				if ($_ > 0 and defined $keys[$_-1]) {
		    		$hashref->{$keys[$_-1]} = $hashref->{$keys[$_-1]} ? 0 : 1;
		    	}
			}
	    }
    }
}

#
# Tomando un hash como parametro (referencia), de la forma %hash -> {key: 0 or 1},
# Devuelve un string con el maximo elemento y su valor entre parentesis
#
sub global_max {
	my $hash = shift;
	my @sorted_keys = sort {$hash->{$b} <=> $hash->{$a}} keys %$hash;
	return @sorted_keys ? "$sorted_keys[0] ($hash->{$sorted_keys[0]})" : 'Ninguno';
}

#
# Tomando un hash como parametro (referencia), de la forma %hash -> {key: 0 or 1},
# Devuelve un string con todos los elementos con valor 0 o ninguno
#
sub global_cero {
	my $hash = shift;
	my @list = ();
	foreach $key (keys %$hash) {
		if (!$hash->{$key}) {
			push(@list, "$key");
		}
	}
	if (@list) {
		return join(', ', @list);
	}
	else {
		return 'Ninguno';
	}
}

#
# Tomando un hash como parametro (referencia), de la forma %hash -> {key: 0 or 1},
# Devuelve un string con el maximo elemento y su valor entre parentesis
#
sub global_max5 {
	my $hash = shift;
	my @sorted_keys = sort {$hash->{$b} <=> $hash->{$a}} keys %$hash;
	my $max = @sorted_keys >= 5 ? 4 : @sorted_keys-1;
	my @list = ();
	foreach (@sorted_keys[0..$max]) {
		push(@list, "$_ ($hash->{$_})")
	}
	if (@list) {
		return join(', ', @list);
	}
	else {
		return 'Ninguno';
	}
}

sub global_min5 {
	my $hash = shift;
	my @sorted_keys = sort {$hash->{$a} <=> $hash->{$b}} keys %$hash;
	my $max = @sorted_keys >= 5 ? 4 : @sorted_keys-1;
	my @list = ();
	foreach (@sorted_keys[0..$max]) {
		push(@list, "$_ ($hash->{$_})")
	}
	if (@list) {
		return join(', ', @list);
	}
	else {
		return 'Ninguno';
	}
}


# Abro el archivo maestro de patrones\
%patterns_def = ();
%patterns_keys = ();
open(PATRONES, "<$ENV{'MAEDIR'}/patrones") or die "No puede abrir el archivo de patrones";
while ($linea = <PATRONES>) {
	$linea =~ /(\d+),'(.*)',/;
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
	    print "\np: Patrones: " . str_seleccion(%patterns) . "\n";
	    print "c: Ciclos: " . str_seleccion(%ciclos) . "\n";
	    print "a: Archivos: " . str_seleccion(%archivos) . "\n";
	    print "\ni: Imprimir informe\n";
	    print "x: Salir\n";
	    print "\nSeleccione alguno de los siguientes filtros o comandos: ";
	    my $opcion = <STDIN>;
	    chomp($opcion);
		if ($opcion =~ /^x$/) {
	    	$finish = 1;
	    }
		if ($opcion =~ /^p$/) {
	    	hash_selection(\%patterns);
	    }
		if ($opcion =~ /^c$/) {
	    	hash_selection(\%ciclos);
	    }
		if ($opcion =~ /^a$/) {
	    	hash_selection(\%archivos);
	    }
		if ($opcion =~ /^i$/) {
			if ( hash_vacio(%patterns) or hash_vacio(%ciclos) or hash_vacio(%archivos) ) {
				print color 'red' ;
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
else {
	%patterns = ();
	%ciclos = ();
	%archivos = ();
	%sistemas = ();
	my $finish = 0;
	while( ! $finish ) {
		%hallazgos = (
			ciclos => {},
			archivos => {},
			sistemas => {},
			patrones => {}
		);
		foreach (@flist) {
			# ignorar . y .. :
			next if ($_ eq "." || $_ eq "..");
			if ($_  =~ /rglobales.([0-9]+)/) {
				$patron_id = $1;
				$patterns{$patterns_def{$patron_id}} = 1 if ! defined $patterns{$patterns_def{$patron_id}};
				open (RESULTADO,"<$ENV{'PROCDIR'}/$_") || die "ERROR: No puedo abrir el fichero $ENV{'PROCDIR'}/$_\n";
				while ($linea = <RESULTADO>) {
					($ciclo, $archivo, $patron, $tipo, $desde, $hasta, $cantidad) = split(',', $linea);
					$ciclos{$ciclo} = 1 if ! defined $ciclos{$ciclo};
					$archivos{$archivo} = 1 if ! defined $archivos{$archivo};
					$sistema = $1 if ($archivo =~ /(.*)_/);
					$sistemas{$sistema} = 1 if ! defined $sistemas{$sistema};
					if ($sistemas{$sistema} and $ciclos{$ciclo} and $archivos{$archivo} and $patterns{$patterns_def{$patron_id}}) {
						$hallazgos{ciclos}{$ciclo} += $cantidad;
						$hallazgos{archivos}{$archivo} += $cantidad;
						$hallazgos{sistemas}{$sistema} += $cantidad;
						$hallazgos{patrones}{$patterns_def{$patron_id}} += $cantidad;
					}
				}
				close(RESULTADO);
			}
		}

		# filtro por el rango de hallazgos
		if (defined $rango_x and defined $rango_y) {
			foreach $key (keys %hallazgos) {
				my $hash_tmp = $hallazgos{$key};
				foreach $item (keys %$hash_tmp) {
					if ($hallazgos{$key}{$item} < $rango_x or $hallazgos{$key}{$item} > $rango_y) {
						delete $hallazgos{$key}{$item};
					}
				}
			}
		}

		print "\nMayor cantidad de hallazgos en patrones: " . global_max($hallazgos{patrones}) . "\n";
		print "Mayor cantidad de hallazgos en sistemas: " . global_max($hallazgos{sistemas}) . "\n";
		print "Mayor cantidad de hallazgos en archivos: " . global_max($hallazgos{archivos}) . "\n";
		print "Patrones con ningún hallazgo: " . global_cero($hallazgos{patrones}) . "\n";
		print "Sistemas con ningún hallazgo: " . global_cero($hallazgos{sistemas}) . "\n";
		print "Archivos con ningún hallazgo: " . global_cero($hallazgos{archivos}) . "\n";
		print "Los 5 patrones con más hallazgos: " . global_max5($hallazgos{patrones}) . "\n";
		print "Los 5 patrones con menos hallazgos: " . global_min5($hallazgos{patrones}) . "\n";
	    print "\np: Patrones seleccionados: " . str_seleccion(%patterns) . "\n";
	    print "c: Ciclos seleccionados: " . str_seleccion(%ciclos) . "\n";
	    print "a: Archivos seleccioandos: " . str_seleccion(%archivos) . "\n";
	    print "s: Sistemas seleccioandos: " . str_seleccion(%sistemas) . "\n";
	    print "r: Rango de hallazgos: " . ((defined $rango_x and defined $rango_y) ? "$rango_x-$rango_y\n" : "Todos\n") ;
	    print "x: Salir\n";
	    print "\nSeleccione alguno de los siguientes filtros o comandos: ";
	    my $opcion = <STDIN>;
	    chomp($opcion);
		if ($opcion =~ /^x$/) {
	    	$finish = 1;
	    }
		if ($opcion =~ /^p$/) {
	    	hash_selection(\%patterns);
	    }
		if ($opcion =~ /^c$/) {
	    	hash_selection(\%ciclos);
	    }
		if ($opcion =~ /^a$/) {
	    	hash_selection(\%archivos);
	    }
		if ($opcion =~ /^s$/) {
	    	hash_selection(\%sistemas);
	    }
		if ($opcion =~ /^r$/) {
			my $finish = 0;
			while( ! $finish ) {
			    print "\nIngrese el rango de hallazgos en la forma x-y, x para salir o t para todos: ";
			    my $opcion = <STDIN>;
			    chomp($opcion);
				if ($opcion =~ /^x$/) {
			    	$finish = 1;
			    }
				if ($opcion =~ /^t$/) {
					$finish = 1;
			    	undef $rango_x;
			    	undef $rango_y;
			    }
				if ($opcion =~ /^(\d+)-(\d+)$/) {
					$finish = 1;
					$rango_x = $1;
					$rango_y = $2;
			    }
		    }
	    }
	}
}
