#!/bin/bash

# PROBLEMA

../../PLANIF/lpg-td-1.0 -o ./dominio.pddl -f ./problema.pddl -n 2 -out ./outputs/problema/lpg > ./outputs/problema/lpg.txt
    
../../PLANIF/optic-clp ./dominio.pddl ./problema.pddl > ./outputs/problema/optic.txt

# PROBLEMA_HIGHSPEED

../../PLANIF/lpg-td-1.0 -o ./dominio.pddl -f ./problema_highspeed.pddl -n 2 -out ./outputs/problema_highspeed/lpg > ./outputs/problema_highspeed/lpg.txt
    
../../PLANIF/optic-clp ./dominio.pddl ./problema_highspeed.pddl > ./outputs/problema_highspeed/optic.txt

# PROBLEMA_SHORTDISTANCE

../../PLANIF/lpg-td-1.0 -o ./dominio.pddl -f ./problema_shortdistance.pddl -n 2 -out ./outputs/problema_shortdistance/lpg > ./outputs/problema_shortdistance/lpg.txt
    
../../PLANIF/optic-clp ./dominio.pddl ./problema_shortdistance.pddl > ./outputs/problema_shortdistance/optic.txt

# PROBLEMA_WEIGHT

../../PLANIF/lpg-td-1.0 -o ./dominio.pddl -f ./problema_weight.pddl -n 2 -out ./outputs/problema_weight/lpg > ./outputs/problema_weight/lpg.txt
    
../../PLANIF/optic-clp ./dominio.pddl ./problema_weight.pddl > ./outputs/problema_weight/optic.txt

# PROBLEMA_TODOS

../../PLANIF/lpg-td-1.0 -o ./dominio.pddl -f ./problema_todos.pddl -n 2 -out ./outputs/problema_todos/lpg > ./outputs/problema_todos/lpg.txt
    
../../PLANIF/optic-clp ./dominio.pddl ./problema_todos.pddl > ./outputs/problema_todos/optic.txt

