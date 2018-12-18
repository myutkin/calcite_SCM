# calcite_SCM
A set of scripts and instruction files to reproduce SCM model published in 10.2118/182829-PA

# Requirements

 - Python3 (tested with v 3.6.1)
	- SymPy (v 1.3)
	- NumPy (v 1.15.0)
	- Pandas (v 0.23.4)
	- Argparse (v 1.1)
 - Cygwin (tested with 2.887 64 bit)
 - GNU make (tested with 4.2.1)
 - GNU plot (tested with v 5.0 patchlevel 6)
 - PHREEQC (tested with 3.3.3-10424-x64)
 - R (tested with 3.4.3) -- is used to generate dynamic PHREEQC input files but can be replaced with Python

# Usage

In order to reproduce SCM figure from the manuscript in png format:
1) Update PHREEQC_BIN and DATABASE_PATH variable according to your environment
2) From bash (cygwin terminal) run ```make -f SCM.make graph_all.svg convert_png```

In general, python script should accept any PHREEQC generated tsv file with proper format and sequence of columns (this is important, take time to make sure order of columns matches the required format). So, surface properties can be calculated for any simple brine composition. For more complex brines, corresponding reactions have to be introduced into the model (equations). Also, mind that this model does not take into account interaction of sodium and chloride with the surface.
