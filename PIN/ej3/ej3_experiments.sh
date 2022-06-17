#!/bin/bash

# 1. DES-COMENTAR la acción REFUEL del dominio 

# RENOVABLE / PROBLEMA_T

../../PLANIF/lpg -o ./dominio.pddl -f ./problema_t.pddl -n 2 -out ./outputs/renovable/problema_t/lpg > ./outputs/renovable/problema_t/lpg.txt
    
../../PLANIF/optic-clp ./dominio.pddl ./problema_t.pddl > ./outputs/renovable/problema_t/optic.txt

# RENOVABLE / PROBLEMA_R

../../PLANIF/lpg -o ./dominio.pddl -f ./problema_r.pddl -n 2 -out ./outputs/renovable/problema_r/lpg > ./outputs/renovable/problema_r/lpg.txt
    
../../PLANIF/optic-clp ./dominio.pddl ./problema_r.pddl > ./outputs/renovable/problema_r/optic.txt

# RENOVABLE / PROBLEMA_R_BIGFUEL

../../PLANIF/lpg -o ./dominio.pddl -f ./problema_r_bigfuel.pddl -n 2 -out ./outputs/renovable/problema_r_bigfuel/lpg > ./outputs/renovable/problema_r_bigfuel/lpg.txt
    
../../PLANIF/optic-clp ./dominio.pddl ./problema_r_bigfuel.pddl > ./outputs/renovable/problema_r_bigfuel/optic.txt

# RENOVABLE / PROBLEMA_R_BIGFUELSMALLBURN

../../PLANIF/lpg -o ./dominio.pddl -f ./problema_r_bigfuelsmallburn.pddl -n 2 -out ./outputs/renovable/problema_r_bigfuelsmallburn/lpg > ./outputs/renovable/problema_r_bigfuelsmallburn/lpg.txt
    
../../PLANIF/optic-clp ./dominio.pddl ./problema_r_bigfuelsmallburn.pddl > ./outputs/renovable/problema_r_bigfuelsmallburn/optic.txt

# RENOVABLE / PROBLEMA_R_REFUELTIME

../../PLANIF/lpg -o ./dominio.pddl -f ./problema_r_refueltime.pddl -n 2 -out ./outputs/renovable/problema_r_refueltime/lpg > ./outputs/renovable/problema_r_refueltime/lpg.txt
    
../../PLANIF/optic-clp ./dominio.pddl ./problema_r_refueltime.pddl > ./outputs/renovable/problema_r_refueltime/optic.txt

# RENOVABLE / PROBLEMA_R_SMALLBURN

../../PLANIF/lpg -o ./dominio.pddl -f ./problema_r_smallburn.pddl -n 2 -out ./outputs/renovable/problema_r_smallburn/lpg > ./outputs/renovable/problema_r_smallburn/lpg.txt
    
../../PLANIF/optic-clp ./dominio.pddl ./problema_r_smallburn.pddl > ./outputs/renovable/problema_r_smallburn/optic.txt

# 2. COMENTAR la acción REFUEL del dominio

# NO_RENOVABLE / PROBLEMA_T

../../PLANIF/lpg -o ./dominio.pddl -f ./problema_t.pddl -n 2 -out ./outputs/no_renovable/problema_t/lpg > ./outputs/no_renovable/problema_t/lpg.txt
    
../../PLANIF/optic-clp ./dominio.pddl ./problema_t.pddl > ./outputs/no_renovable/problema_t/optic.txt

# NO_RENOVABLE / PROBLEMA_R

../../PLANIF/lpg -o ./dominio.pddl -f ./problema_r.pddl -n 2 -out ./outputs/no_renovable/problema_r/lpg > ./outputs/no_renovable/problema_r/lpg.txt
    
../../PLANIF/optic-clp ./dominio.pddl ./problema_r.pddl > ./outputs/no_renovable/problema_r/optic.txt

# NO_RENOVABLE / PROBLEMA_R_BIGFUEL

../../PLANIF/lpg -o ./dominio.pddl -f ./problema_r_bigfuel.pddl -n 2 -out ./outputs/no_renovable/problema_r_bigfuel/lpg > ./outputs/no_renovable/problema_r_bigfuel/lpg.txt
    
../../PLANIF/optic-clp ./dominio.pddl ./problema_r_bigfuel.pddl > ./outputs/no_renovable/problema_r_bigfuel/optic.txt

# NO_RENOVABLE / PROBLEMA_R_BIGFUELSMALLBURN

../../PLANIF/lpg -o ./dominio.pddl -f ./problema_r_bigfuelsmallburn.pddl -n 2 -out ./outputs/no_renovable/problema_r_bigfuelsmallburn/lpg > ./outputs/no_renovable/problema_r_bigfuelsmallburn/lpg.txt
    
../../PLANIF/optic-clp ./dominio.pddl ./problema_r_bigfuelsmallburn.pddl > ./outputs/no_renovable/problema_r_bigfuelsmallburn/optic.txt

# NO_RENOVABLE / PROBLEMA_R_REFUELTIME

../../PLANIF/lpg -o ./dominio.pddl -f ./problema_r_refueltime.pddl -n 2 -out ./outputs/no_renovable/problema_r_refueltime/lpg > ./outputs/no_renovable/problema_r_refueltime/lpg.txt
    
../../PLANIF/optic-clp ./dominio.pddl ./problema_r_refueltime.pddl > ./outputs/no_renovable/problema_r_refueltime/optic.txt

# NO_RENOVABLE / PROBLEMA_R_SMALLBURN

../../PLANIF/lpg -o ./dominio.pddl -f ./problema_r_smallburn.pddl -n 2 -out ./outputs/no_renovable/problema_r_smallburn/lpg > ./outputs/no_renovable/problema_r_smallburn/lpg.txt
    
../../PLANIF/optic-clp ./dominio.pddl ./problema_r_smallburn.pddl > ./outputs/no_renovable/problema_r_smallburn/optic.txt


