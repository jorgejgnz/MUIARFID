(define (problem ej1_problema_mini3)
(:domain ej1_dominio_aeropuerto)
(:objects
    Loc1 Loc2 - localizacion
    Vag1 - vagoneta
    Vag2 - vagoneta
    Maq1 - maquina
    Maq2 - maquina
    Equip1 - equipaje
    Equip2 - equipaje
    Equip3 - equipaje
    N1 N2 - numero
)

(:init
    ;; localizaciones
    (adyacent Loc1 Loc2)
    (adyacent Loc1 OficinaInspeccion)
    (adyacent Loc2 Loc1)
    (adyacent OficinaInspeccion Loc1)
    ;; maquinas
    (at Maq1 Loc1)
    (at Maq2 Loc2)
    (last Maq1 Vag1)
    (last Maq2 Maq2)
    (follow Vag1 Maq1)
    (follow Maq1 Maq1)
    (follow Maq2 Maq2)
    (connected Vag1 Maq1)
    ;; vagonetas
    (waiting Vag2 OficinaInspeccion)
    ;; equipajes
    (waiting Equip1 Loc2)
    (occupied Vag1 Equip2)
    (occupied Vag1 Equip3)
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
    (carried Vag1 N2)
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
