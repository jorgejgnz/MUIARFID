(define (problem ej2_problema)
(:domain ej2_dominio_aeropuerto)
(:objects
    ZonaFacturacion RecogidaEquipaje - localizacion
    P1 P2 P3 P4 P5 P6 P7 P8 - localizacion
    V1 V2 V3 V4 V5 - vagoneta
    M1 - maquina
    M2 - maquina
    E1 E2 E3 E4 E5 E6 - equipaje
)

(:init
    ; locations
    (adyacent ZonaFacturacion RecogidaEquipaje)
    (adyacent ZonaFacturacion OficinaInspeccion)
    (adyacent ZonaFacturacion P2)
    (adyacent RecogidaEquipaje ZonaFacturacion)
    (adyacent RecogidaEquipaje OficinaInspeccion)
    (adyacent RecogidaEquipaje P6)    
    (adyacent OficinaInspeccion RecogidaEquipaje)    
    (adyacent OficinaInspeccion ZonaFacturacion)
    (adyacent OficinaInspeccion P1)
    (adyacent OficinaInspeccion P5)
    (adyacent P1 OficinaInspeccion)
    (adyacent P1 P3)
    (adyacent P2 ZonaFacturacion)
    (adyacent P2 P4)
    (adyacent P3 P1)
    (adyacent P3 P4)
    (adyacent P4 P3)
    (adyacent P4 P2)
    (adyacent P5 OficinaInspeccion)
    (adyacent P5 P7)
    (adyacent P6 RecogidaEquipaje)
    (adyacent P6 P8)
    (adyacent P7 P5)
    (adyacent P7 P8)
    (adyacent P8 P6)
    (adyacent P8 P7)

    ;maquinas
    (at M1 RecogidaEquipaje) 
    (follow M1 M1)
    (last M1 M1)
    
    (at M2 RecogidaEquipaje) 
    (follow M2 M2)
    (last M2 M2)

    ;vagonetas
    (waiting V1 P1)
    (waiting V2 P1)
    (waiting V3 P1)
    (waiting V4 P5)
    (waiting V5 P5)
    
    ;equipaje
    (notdanger E1)
    (destination E1 P4)
    (waiting E1 ZonaFacturacion)

    (notdanger E2)
    (destination E2 P8)
    (waiting E2 ZonaFacturacion)

    (danger E3)
    (destination E3 RecogidaEquipaje)
    (waiting E3 P6)

    (notdanger E4)
    (destination E4 RecogidaEquipaje)
    (waiting E4 P6)

    (notdanger E5)
    (destination E5 RecogidaEquipaje)
    (waiting E5 P2)

    (danger E6)
    (destination E6 RecogidaEquipaje)
    (waiting E6 P2)
    
    ;estado de las vagonetas
    (= (elements V1) 0)
    (= (elements V2) 0)
    (= (elements V3) 0)
    (= (elements V4) 0)
    (= (elements V5) 0)

    ;distancias (zona-zona:4, zona-puerta:3, puerta-puerta:2)
    (= (distance ZonaFacturacion RecogidaEquipaje) 20)
    (= (distance ZonaFacturacion OficinaInspeccion) 20)
    (= (distance ZonaFacturacion P2) 15)
    (= (distance RecogidaEquipaje ZonaFacturacion) 20)
    (= (distance RecogidaEquipaje OficinaInspeccion) 20)
    (= (distance RecogidaEquipaje P6) 15)
    (= (distance OficinaInspeccion RecogidaEquipaje) 20)
    (= (distance OficinaInspeccion ZonaFacturacion) 20)
    (= (distance OficinaInspeccion P1) 15)
    (= (distance OficinaInspeccion P5) 15)
    (= (distance P1 OficinaInspeccion) 15)
    (= (distance P1 P3) 10)
    (= (distance P2 ZonaFacturacion) 15)
    (= (distance P2 P4) 10)
    (= (distance P3 P1) 10)
    (= (distance P3 P4) 10)
    (= (distance P4 P3) 10)
    (= (distance P4 P2) 10)
    (= (distance P5 OficinaInspeccion) 15)
    (= (distance P5 P7) 10)
    (= (distance P6 RecogidaEquipaje) 15)
    (= (distance P6 P8) 10)
    (= (distance P7 P5) 10)
    (= (distance P7 P8) 10)
    (= (distance P8 P6) 10)
    (= (distance P8 P7) 10)

    ;velocidades
    (= (speed M1) 8)
    (= (speed M2) 4)

    ;capacidades
    (= (capacity V1) 2)
    (= (capacity V2) 2)
    (= (capacity V3) 2)
    (= (capacity V4) 2)
    (= (capacity V5) 2)

    ;pesos
    (= (weight E1) 20)
    (= (weight E2) 40)
    (= (weight E3) 60)
    (= (weight E4) 20)
    (= (weight E5) 40)
    (= (weight E6) 60)
)

(:goal (and
    (done E1)
    ;(notdanger E1)
    (done E2)
    ;(notdanger E2)
    (done E3)
    ;(notdanger E3)
    (done E4)
    ;(notdanger E4)
    (done E5)
    ;(notdanger E5)
    (done E6)
    ;(notdanger E6)
))

(:metric minimize (total-time))
)
