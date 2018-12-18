args=(commandArgs(TRUE))

filename    =args[1]
co2_string  =args[2]
co2_press   =as.numeric(args[3])


h1 = file(paste0(filename, ".pqi"), open='w')

  cat(paste0('
    
    SOLUTION 1 ACID
    
    temp      25
    pH        7 charge
    pe        4
    redox     pe
    units     mol/L
    density   1
    -water    1 # kg
    
    Na 0.11
    Cl 0.21
    
    SOLUTION 2 BASE
    temp      25
    pH        7 charge
    pe        4
    redox     pe
    units     mol/L
    density   1
    -water    1 # kg
    
    Na 0.21
    Cl 0.11
    
   
    SOLUTION_SPECIES
    H+ + HCO3- = H2CO3
    log_k     3.76
    CO3-2 + H+ = HCO3-
      log_k     10.329
    H2CO3 = CO2 + H2O
    log_k     2.59
    
    
    END
    
    SELECTED_OUTPUT 1
    -file    ',             filename, '.tsv', '\n', '
    -high_precision       true
    -reset                false
    -pH                   true
    -ionic_strength       true
    -percent_error        true
    -molalities           H+  OH-  Ca+2  CaHCO3+
      CaOH+  CO3-2  HCO3-  CO2
    H2CO3 Na+ Cl-
      
  
    USER_PUNCH 1
    -headings gamma_H gamma_OH gamma_Ca gamma_CaHCO3 gamma_CaOH gamma_CO3 gamma_HCO3 gamma_H2CO3 gamma_CO2 pressure mu
    -start
    10
    20
    30 g_H = GAMMA("H+")
    40 g_OH = GAMMA("OH-")
    50 g_Ca = GAMMA("Ca+2")
    60 g_CaHCO3 = GAMMA("CaHCO3+")
    70 g_CaOH = GAMMA("CaOH+")
    80 g_CO3 = GAMMA("CO3-2")
    90 g_HCO3 = GAMMA("HCO3-")
    100 g_H2CO3 = GAMMA("H2CO3")
    110 g_CO2 = GAMMA("CO2")
    120 PUNCH g_H
    130 PUNCH g_OH
    140 PUNCH g_Ca
    150 PUNCH g_CaHCO3
    160 PUNCH g_CaOH
    170 PUNCH g_CO3
    180 PUNCH g_HCO3
    190 PUNCH g_H2CO3
    200 PUNCH g_CO2
    210 pr = SI("CO2(g)")
    220 PUNCH pr
    230 PUNCH MU
    -end'), file=h1)

if(co2_press == -3.44) {mix_rat = 30}
if(co2_press == -5.2) {mix_rat = 30}
if(co2_press == 0) {mix_rat = 100}

if(co2_press != 0){       
for(i in seq(mix_rat, 5, -5)){
  cat(paste0('
            SOLUTION 3; units mol/L; 
             Na  0.11
             Cl  0.11
             USE solution 3; 
             EQUILIBRIUM_PHASES 3; Calcite 0 10; CO2(g) -3.44  10; 
             END
             MIX 1
             3 100
             1  ' ,i, '\n', '
             SAVE SOLUTION 4
             END
             USE SOLUTION 4; EQUILIBRIUM_PHASES 4; Calcite 0 10; CO2(g)  ', co2_press, '  10; 
             END'
    
  ), file=h1, append=TRUE)
}
}
  
for(i in seq(5, mix_rat, 5)){
    cat(paste0('
               SOLUTION 3; units mol/L; 
               Na  0.11
               Cl  0.11
               USE solution 3; 
               EQUILIBRIUM_PHASES 3; Calcite 0 10; CO2(g) -3.44  10; 
               END
               MIX 1
               3 100
               2  ' ,i, '\n', '
               SAVE SOLUTION 4
               END
               USE SOLUTION 4; EQUILIBRIUM_PHASES 4; Calcite 0 10; CO2(g)  ', co2_press, '  10; 
               END'
               
    ), file=h1, append=TRUE)  
      

}  
  
  
  close(h1)