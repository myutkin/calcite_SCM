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
set y2range [0.09 : 0.11]

set xlabel "pH" offset  0,0.5
set ylabel "Zeta, potential, mV" offset  2,0
set y2label "Ionic strength, M" offset  -5,0

set xtics mirror
set ytics mirror
#unset mytics
set y2tics
#set logscale y 10
#set mytics 10


# set offsets <left>, <right>, <top>, <bottom>
set offsets graph 0, 0.05, 0.05, 0
set key  Right at graph 0.75, 0.225  font "Times New Roman,20" maxrows 4 width -4 samplen 2

#unset key



plot 	calc350 		using 11:($16*1000) title "Model 350 ppm" smooth unique with lines ls 1, \
		calc6 			using 11:($16*1000) title "Model 6 ppm" smooth unique with lines ls 2, \
		calc1000000 	using 11:($16*1000) title "Model 1000000 ppm" smooth unique with lines ls 3, \
		NaN 			title "Ionic strength" ls 4 dt 4 lw 0.5, \
		calc350 		using 11:12 axes x1y2 notitle smooth unique with lines ls 1 dt 4 lw 0.7, \
		calc6 			using 11:12 axes x1y2 notitle smooth unique with lines ls 2 dt 4 lw 0.7, \
		calc1000000 	using 11:12 axes x1y2 notitle smooth unique with lines ls 3 dt 4 lw 0.7, \
		exp350 			using 2:3 title "Exp 350 ppm"  with points ls 1, \
		exp6 			using 2:3 title "Exp 6 ppm"  with points ls 2, \
		exp1000000 		using 2:3 title "Exp 1000000 ppm"  with points ls 3
