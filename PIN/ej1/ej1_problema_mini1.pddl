(define (problem ej1_problema_mini1)
(:domain ej1_dominio_aeropuerto)
(:objects
    Loc1 Loc2 - localizacion
    Vag1 - vagoneta
    Maq1 - maquina
    Equip1 - equipaje
    N1 N2 - numero
)

(:init
    ;; localizaciones
    (adyacent Loc1 Loc2)
    (adyacent Loc1 OficinaInspeccion)
    (adyacent Loc2 Loc1)
    (adyacent OficinaInspeccion Loc1)
    ;; transporte
    (at Maq1 Loc1)
    (last Maq1 Vag1)
    (follow Vag1 Maq1)
    (connected Vag1 Maq1)
    ;; equipajes
    (waiting Equip1 Loc2)
    (destination Equip1 Loc1)
    (danger Equip1)

    ;numeros
    (next zero N1)
    (next N1 N2)
    
    ;estado de las vagonetas
    (carried Vag1 zero)
)

(:goal (and
    (done Equip1)
    (notdanger Equip1)
))
)
