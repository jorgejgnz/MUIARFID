(define (problem ej1_problema_mini4)
(:domain ej1_dominio_aeropuerto)
(:objects
    Loc1 Loc2 - localizacion
    Vag1 Vag2 - vagoneta
    Maq1 Maq2 - maquina
    Equip1 Equip2 Equip3 - equipaje
    N1 N2 - numero
)

(:init
    ;; localizaciones
    (adyacent Loc1 Loc2)
    (adyacent Loc1 OficinaInspeccion)
    (adyacent Loc2 Loc1)
    (adyacent OficinaInspeccion Loc1)
    ;; maquinas
    (at Maq1 OficinaInspeccion)
    (at Maq2 Loc2)
    (last Maq1 Maq1)
    (last Maq2 Maq2)
    (follow Maq1 Maq1)
    (follow Maq2 Maq2)
    ;; vagonetas
    (waiting Vag1 Loc1)
    (waiting Vag2 Loc1)
    ;; equipajes
    (waiting Equip1 Loc2)
    (waiting Equip2 Loc1)
    (waiting Equip3 OficinaInspeccion)
    (destination Equip1 Loc1)
    (destination Equip2 Loc2)
    (destination Equip3 Loc2)
    (danger Equip1)
    (notdanger Equip2)
    (notdanger Equip3)
    ;numeros
    (next zero N1)
    (next N1 N2)  
    ;estado de las vagonetas
    (carried Vag1 zero)
    (carried Vag2 zero)
)

(:goal (and
    (done Equip1)
    (notdanger Equip1)
    (done Equip2)
    (notdanger Equip2)
    (done Equip3)
    (notdanger Equip3)
))
)
