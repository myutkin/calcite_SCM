DATABASE_PATH = '.\phreeqc-3.3.3-10424-x64\database\phreeqc.dat'
PHREEQC_BIN = '.\phreeqc-3.3.3-10424-x64\bin\phreeqc.bat'
MAKEFLAGS += --no-print-directory
where-am-i = $(CURDIR)/$(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST))
THIS_MAKEFILE := $(call where-am-i)
SVG = $(wildcard *.svg)
PNG = $(patsubst %.svg,%.png,$(SVG))
PYTHON_PATH='C:/python36/python.exe'
.PRECIOUS: %.pqi %.tsv
# this is a more or less universal guess, but it does not work for 1 atm
guess=-0.1 0.1 0.001 -0.0001 0.5 0.5 0.1 0.1 0.1 0.1 0.1
iter=50

# unique guesses obtained by adjustment, syntax is random
# guess1 = [-0.728961149115028,0.728961149115028,-0.0678880468065579,-0.0127260895096222,0.910463014161912,0.000956890580116238,9.75635449850764e-06,0.101059660584454,3.93846756889914,1.96558485693120,2.98345825248869]';%sguess(:,1);
# guess350  = [1.98117617761968,-1.98117617761968,0.185885974795589,0.0359663860215679,0.00284737689572112,-0.00292522270594665,0.0127992897328673,0.0992901542132158,4.83506317915820,-3.42817956296994e-05,4.95295950450158]'; %sguess(:,1);
# guess6  = [2.05915245422584,-2.05915245422584,0.193884609503224,0.0380643989394881,0.000813768110772643,-0.0343926791196656,0.0504624040237185,0.00765143974409969,4.89107238812141,-9.61971299347487e-06,4.98440229883266]';%sguess1(:,1);
 


############## CLEANING BLOCK ######################
clean_tmp:
	rm -f *.pqi *.pqo *.tmp *.log *.out *.Rout .RData *.inp

clean_out:
	rm -f *.tsv *.csv
	
clean_svg: 
	rm -f *.svg

clean_png:
	rm -f *.png

###################################################



%.pqi: pc_input.R
	R CMD BATCH --no-restore '--args $(basename $(@F)) dummy $(co2_press)' $<

%.tsv: %.pqi
	cmd /c $(PHREEQC_BIN) $< OUTPUT.tmp $(DATABASE_PATH)
	
%.csv: %.tsv
	$(PYTHON_PATH) run_SCM.py --filename $(basename $(@F)) --guess $(guess) --iter $(iter)

bulk_350_surface.csv: co2_press='-3.44'
bulk_6_surface.csv: co2_press='-5.2'
bulk_1000000_surface.csv: co2_press='0'
bulk_1000000_surface.csv: guess=0.59179 -0.59179 0.048123 0.010203 0.30021 0.28992 0.00018937 4.6124 0.037168 4.5963 0.063825
	
graph_all.svg: graph.plt bulk_350_surface.csv bulk_6_surface.csv bulk_1000000_surface.csv heberling_pco2_-3.44.txt heberling_pco2_-5.2.txt heberling_pco2_1.txt
		gnuplot -c $^

# weird staff that 100000 ppm makes is because of high ionic strength
# there is another approach to titration through addition of Ca or CO3 ions, 
# which I may implement later
		
############## IMAGE CONVERSION BLOCK ######################
	
	
convert_png: $(PNG)

%.png: %.svg
	cmd /c "C:\Program Files\Inkscape\inkscape.exe" --without-gui --file="$<" --export-png="$@" --export-dpi=300
	
###################################################