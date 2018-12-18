load 'settings.gp'


set output 'graph_all.svg'

calc350 = ARG1
calc6 = ARG2
calc1000000 = ARG3
exp350 = ARG4
exp6 = ARG5
exp1000000 = ARG6

#set xrange [0 : 0.7]
#set yrange [0 : 1]

set xlabel "pH" offset  0,0.5
set ylabel "Zeta, potential, mV" offset  2,0

set xtics mirror
set ytics mirror
#unset mytics
#set y2tics
#set logscale y 10
#set mytics 10


# set offsets <left>, <right>, <top>, <bottom>
set offsets graph 0, 0.05, 0.05, 0
set key  Right at graph 0.75, 0.2  font "Times New Roman,14" maxrows 3 width -4 samplen 2

#unset key



plot 	calc350 		using (-log10($6)):($14*1000) title "Model 350 ppm" with lines ls 1, \
     	calc6 			using (-log10($6)):($14*1000) title "Model 6 ppm" with lines ls 2, \
     	calc1000000 	using (-log10($6)):($14*1000) title "Model 1000000 ppm" with lines ls 3, \
     	exp350 			using 2:3 title "Exp 350 ppm"  with points ls 1, \
     	exp6 			using 2:3 title "Exp 6 ppm"  with points ls 2, \
     	exp1000000 		using 2:3 title "Exp 1000000 ppm"  with points ls 3, \