set datafile separator "\t"
set encoding utf8
set minussign
set terminal svg enhanced font "Times New Roman,18"

#set format y "%2.1t×10^{%L}"

# Some line styles
set style line 1 lt 1 lc rgb "red"  		lw 2 		ps 0.7 pt 4# Tracer
set style line 2 lt 1 lc rgb "blue"  		lw 2 dt 2 	ps 0.7 pt 6# Ca
set style line 3 lt 1 lc rgb "dark-green"  	lw 2 dt 3 	ps 0.7 pt 8# Mg
set style line 4 lt 1 lc rgb "black"  		lw 2 dt 4 	ps 0.7 pt 10#
set style line 5 lt 1 lc rgb "blue"  		lw 2 dt 5	ps 0.7 pt 12#
