import pandas as pd
import sympy as sp
import numpy as np
import argparse
import os
import sys

abspath = os.path.abspath(__file__)
dname = os.path.dirname(abspath)
os.chdir(dname)

class Store_as_array(argparse._StoreAction):
    def __call__(self, parser, namespace, values, option_string=None):
        values = np.array(values)
        return super().__call__(parser, namespace, values, option_string)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description = 'Calcite SCM driver')
    parser.add_argument('--filename', help = "Bulk conc filename", default="", type=str)
    parser.add_argument('--guess', help = "initial guess for calculations, give it as last argument", action=Store_as_array, type=float, nargs='*')
    #parser.add_argument('--guess', help = "initial guess for calculations", default="", type=str)
    parser.add_argument('--iter', help = "max number of iterations", default=50, type=int)
    parser.add_argument('--err', help = "max error", default=1e-10, type=float)


    args = parser.parse_args(sys.argv[1:])
    filename = args.filename
    iter = args.iter
    err = args.err
    # assert isinstance(args.guess, np.ndarray)
    guess = args.guess
    # print(guess)
    
# sys.exit()

#filename = 'calcite_bulk_speciation_titration_350.csv'


"""
%Reactions
%(1) >CaH2O+          <-->  >CaOH   + H+      (K1)
%(2) >CaH2O+ + HCO3-  <-->  >CaHCO3 + H2O     (K2)
%(3) >CaH2O+ + CO3--  <-->  >CaCO3- + H2O     (K3)
%(4) >CO3-   + H+     <-->  >CO3H             (K4)
%(5) >CO3-   + Ca++   <-->  >CO3Ca+           (K5)
"""
#Given parameters
T = 273+25;     #%[K], (25C)
epsrW = 15;     #%[1]
epsrWhigh = 70; #%[1]

#% %Equilibrium Constants
#% K1 = 10^(-12.9);
#% K2 = 10^(+1.04);
#% K3 = 10^(+3.242);
#% K4 = 10^(+4.9);
#% K5 = 10^(+1.74);

#%ADJUSTED...
K1 = 10**(-10); #% can range from 10^-6 to 10^-12
K2 = 10**(2); #%10^(+1.04);  %1.2
#%K3 = 10^(3) #% 10^(+3.2); % does not really change much
K3 = 10**(3)
K4 = 10**(8); #% makes 1 atm case nonconve
K5 = 10**(3); #% this one really moves them up (and right) if you increase it!!!

#%Calcite Properties
CaH2OSite = 4.95; #%[sites/nm^2]
CO3Site = 4.95; #%[sites/nm^2]
#% SACaCO3 = 2; # This is a lot!  #%[m^2/g]  1.8m^2/g (Hiorth)
#% SAingl = 2*2.71*1e9; #%[m^2/L]

#%Constants
e = 1.602e-19;   #%[C]
Navo = 6.022e23; #%[1/mol]
F = e*Navo;      #%[C/mol]
R = 8.314;       #%[J/K mol]
epso = 8.854e-12; #%[F/m]
eps = epso*epsrW; #%[F/m]
kb = R/Navo;

#%Radius of Ions [nm]
rCa = 0.104; #% from table V. 0.15 and page 1488; and from hanbook "Directory of the Chemist", Ed. B.P. Nikolskiy, Second issue, corrected, Leningrad, Publiching "Chemistry", 1966. volume 1, page 381.
rHCO3 = 0.178; #% we assume it is close to carbonate. 0.3;
rCO3 = 0.178; #% from http://pubs.acs.org/doi/pdf/10.1021/ed056p576 page 577, table. % 0.3;
rH2O = 0.138; #% for ice, we assume they are packed closer. from http://pubs.acs.org/doi/pdf/10.1021/cr00090a003 page 1479, right column, near the end of the page.  0.14; %H3O+ and OH- have very similar sizes (NEED TO CHECK)
rNa = 0.097;  #% page 1484, table II and page 1485%  0.1; % not included in the layer
rCl = 0.180;  #% from table XI and page 1491.
r_avg = (rCa + rH2O + rHCO3 + rCO3)/4;

#%Calculated Parameters
#% >Site-(ION)(H2O)(ION)
#% dx = 0.093 + 0.099 + 0.140 + 0.15; %[nm] (dx(2nd~1st layer water) + dx(water) + dx(ion))
dx2 = r_avg + 2*rH2O + 2*rH2O + r_avg; #%[nm] Maybe better approximate
C2 = 100*eps/(dx2*1e-9) #%[uF/cm^2]

#%sigo, sigd = [uC/cm^2]
#%phio, phid = [V]
#%CaH2O... = [sites/nm^2]


syms,sigb,sigd,phib,phid,CaH2O,CO3,CaOH,CaHCO3,CaCO3,CO3H,CO3Ca = sp.symbols('syms,sigb,sigd,phib,phid,CaH2O,CO3,CaOH,CaHCO3,CaCO3,CO3H,CO3Ca', real=True);

"""
1) charge balance
2) Mass action
3) charge balance
4) Poisson-Boltzman
5) constant capacitance
6) Site balance
"""

def even_mask(data, index):
    even_mask = [i - 1  for i in range(len(data)) if i % index == 0][1:]
    return even_mask

# script = "SCM_calcite.py"
# These are data from phreeqc calculation, so it has to be available before we run it
# This is achieved by using makefile

data_bulk = pd.read_csv(filename + '.tsv', sep="\t")
# we take every 4th line!! it may look like it is doing exactly otherwise, but since nuberimg start from 0 in python ...
data_bulk_even = data_bulk.loc[even_mask(data_bulk, 4),]

data_reshaped = data_bulk_even.iloc[:,[10,11,9,8,3,4,5,12,13]]

# data_reshaped

def NR(concentrations, guess, iter, err):
    
    C = concentrations

    equations = [
            sigb + sigd,
            K1*(CaH2O) - (CaOH)*C[4]*sp.exp(-F*phib/(R*T)),
            K2*(CaH2O)*C[2] - (CaHCO3)*sp.exp(-F*phib/(R*T)),
            K3*(CaH2O)*C[3] - (CaCO3)*sp.exp(-2*F*phib/(R*T)),
            K4*(CO3)*C[4] - (CO3H)*sp.exp(F*phib/(R*T)),
            K5*(CO3)*C[6] - (CO3Ca)*sp.exp(2*F*phib/(R*T)),
            sigb - F*1e6*(1e14/Navo)*(CO3H + 2*CO3Ca - (CaOH + CaHCO3 + 2*CaCO3)),
            sigd + (phid/sp.Abs(phid))*1e2*sp.sqrt(1e3*2*(epso*(0.5)*epsrWhigh)*R*T* \
            (C[4]*(sp.exp(-F*phid/(R*T))-1) + C[6]*(sp.exp(-2*F*phid/(R*T))-1) + \
            C[8]*(sp.exp(-F*phid/(R*T))-1) + \
            C[2]*(sp.exp(F*phid/(R*T))-1) + C[3]*(sp.exp(2*F*phid/(R*T))-1) + \
            C[5]*(sp.exp(F*phid/(R*T))-1) + C[8]*(sp.exp(F*phid/(R*T))-1))),
            C2*(phib - phid) + (sigd),
            CaH2OSite - CaH2O - (CaHCO3 + CaCO3 + CaOH),
            CO3Site - CO3 - (CO3Ca + CO3H)]
    
    x = [sigb, sigd, phib, phid, CaH2O, CO3, CaOH, CaHCO3, CaCO3, CO3H, CO3Ca]
    
    Mat = sp.Matrix([equations])
    
    Funct = sp.utilities.lambdify(x, equations, 'numpy')
    
    
    J = Mat.jacobian(x).doit()
    
    Jac = sp.utilities.lambdify(x, J, modules=['numpy'])
    
    n = 0
    
    for i in range(iter):
        dFdxevalxi = np.matrix(Jac(*guess))  # %dFdx(xi); Jacobian evaluated at xi
        eqevalxi = Funct(*guess)# %F(xi); function F evaluated at xi
        guess = np.dot(-np.linalg.inv(dFdxevalxi),eqevalxi) + guess
        # need toconvert to the right type to feed in next iter
        guess = np.array(guess).reshape(-1)
    
        # Error calc
        error = np.sqrt(np.dot(np.transpose(eqevalxi),eqevalxi))
        # Iter counter
        n = n + 1
        if error < err:
            print('Equation Solved')
            print(error)
            print(n)
            break
    return [guess, error, n]

data_input = data_reshaped.values

# the very first guess was [-0.1;0.1;0.001;-0.0001;0.5;0.5;0.1;0.1;0.1;0.1;0.1]
#initial_guess = [-0.37559395086439135,  0.37559395086439135,  -0.028614353295399634,  -0.004547607403855554,  -8.370127229871269e-08,  2.4867224475964997,  4.950000083789741,  -8.827904840904526e-11,  -1.8862304081356514e-13,  3.3639083506154877e-07,  2.4632772160126652]
# always start with one guess?
#initial_guess = [-0.1,0.1,0.001,-0.0001,0.5,0.5,0.1,0.1,0.1,0.1,0.1]
#guess = initial_guess #np.matrix(initial_guess*len(data_input[:,0]))
guess = guess.tolist()
#guess = guess.reshape((len(initial_guess),len(data_input[:,0])))
surface_calc = list()
all_calc = list()
error_all = list()
iter_all = list()

flatten = lambda l: [item for sublist in l for item in sublist]

for i in range(len(data_input[:,0])):
    concentrations = data_input[i,:]
    #guess[i+1,:] = NR(concentrations,flatten(guess[i,:].tolist()), 50, 1e-10).tolist()
    all_calc.append(NR(concentrations,guess, iter, err))
    surface_calc.append(flatten(all_calc[i][:-2]))
    error_all.append(all_calc[i][-2])
    iter_all.append(all_calc[i][-1])
    #surface_calc.append(flatten(guess[i+1,:].tolist()))
    guess = surface_calc[i]

# expoer here 
header = ['sigb', 'sigd', 'phib', 'phid', 'CaH2O', 'CO3', 'CaOH', 'CaHCO3', 'CaCO3', 'CO3H', 'CO3Ca']

data_surf = pd.DataFrame(surface_calc, columns=header)
data_err = pd.Series(error_all, name = 'Errors')
data_iter = pd.Series(iter_all, name = 'Iterations')

data_calc_export = data_surf.join([data_err, data_iter])

data_reshaped = data_reshaped.reset_index(drop=True)
data_export = data_reshaped.join(data_calc_export)

print('Exporting results ...')
data_export.to_csv(filename + '.csv', sep='\t', encoding='utf-8')