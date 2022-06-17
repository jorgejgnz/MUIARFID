(define (domain ej2_dominio_aeropuerto)

(:requirements :strips :typing :equality :durative-actions :fluents)

(:types
	localizacion
	equipaje
	vagoneta
	maquina
)

(:constants
    OficinaInspeccion - localizacion
)

(:predicates
	;Localizacion ?loc1 adyacente a localizacion ?loc2. No es simetrico.
	(adyacent ?loc1 - localizacion, ?loc2 - localizacion) 
	
	;Maquina ?maq se encuentra en localizacion ?loc
	(at ?maq - maquina ?loc - localizacion)

	;Maquina o vaganota ?v a la que esta conectada la vagoneta ?vag.
	;Efectos necesarios:
	; not (waiting vag loc) 
	; follow vag m
	; last m vag
	(connected ?vag - vagoneta ?v - (either vagoneta maquina))

	;Maquina ?maq a la que sigue la vagoneta ?v.
	(follow ?v - (either vagoneta maquina) ?maq - maquina)

	;Ultima vagoneta ?v de la maquina ?maq.
	;Si no tiene vagoneta enganchada, lo sigue la propia maquina.
	(last ?maq - maquina ?v - (either vagoneta maquina))

	;Equipaje ?equip está en la vagoneta ?vag.
	(occupied ?vag - vagoneta ?equip - equipaje)
	
	;Equipaje ?equip no es sospechoso.
	;Efectos necesarios: 
	; not (notganger eq)
	(danger ?equip - equipaje)

	;Equipaje ?equip es sospechoso.
	;Efectos necesarios: 
	; not (danger eq)
	(notdanger ?equip - equipaje)
	
	;Localizacion de destino ?loc del equipaje ?equip.
	(destination ?equip - equipaje ?loc - localizacion)

	;Equipaje o vagoneta ?x esperando ser recogidos en la localizacion ?loc.
	;Efectos necesarios para vagoneta:
	; not (connected x v)
	; not (follow x m)
	; not (last m x)
	;Efectos necesarios para equipaje:
	; not (toanalyce x)
	; not (done x)
	(waiting ?x - (either equipaje vagoneta) ?loc - localizacion)

	;Equipaje sospechoso ?equip esta en la OficinaInspeccion para ser analizado.
	;Efectos necesarios: 
	; not (waiting eq loc)
	(toanalyce ?equip - equipaje)

	;Equipaje ?equip llega a su destino.
	;Efectos necesarios: 
	; not (waiting eq loc)
	; not (toanalyce eq)
    (done ?equip - equipaje)
)

(:functions
	(distance ?l1 - localizacion ?l2 - localizacion) ;Distancia entre localizaciones
	(speed ?maq - maquina) ;Velocidad de una máquina
	(capacity ?vag - vagoneta) ;Capacidad máxima de una vagoneta	
	(elements ?vag - vagoneta) ;Cantidad actual de equipajes en una vagoneta
	(weight ?equip - equipaje) ;Peso de un equipaje (influye en el tiempo de carga/descarga)
)

(:durative-action move
	:parameters (
		?maq - maquina
		?orig - localizacion
		?dest - localizacion
	)
	:duration (= ?duration (/ (distance ?orig ?dest) (speed ?maq))) ;En función de la distancia y la velocidad de la máquina
	:condition (and
		(at start (at ?maq ?orig))
		(over all (adyacent ?orig ?dest)) ;Las localizaciones deben seguir siendo adyacentes durante el proceso
	)
	:effect (and 
		(at start (not (at ?maq ?orig))) ;La máquina deja de estar en el origen en cuanto empieza a moverse
		(at end (at ?maq ?dest)) ;Pasa a estar en el destino cuando el movimiento termina
	)
)

(:durative-action load
	:parameters (
		?equip - equipaje
		?vag - vagoneta
		?maq - maquina
		?loc - localizacion
	)
	:duration (= ?duration (* 1.5 (weight ?equip))) ;La duración es relativa al peso del equipaje
	:condition (and
		(at start (waiting ?equip ?loc))
		(at start (> (capacity ?vag) (elements ?vag))) ;Debe quedar espacio para cargar el equipaje
		(over all (at ?maq ?loc)) ;La máquina debe permanecer quieta durante el proceso
		(over all (follow ?vag ?maq)) ;La vagoneta debe seguir unida al tren durante el proceso
	)
	:effect (and 
		(at start (not(waiting ?equip ?loc))) ;El equipaje deja de estar disponible para ser usado por otras acciones durante el proceso
		(at start (increase (elements ?vag) 1)) ;El espacio que va a ocupar el equipaje en la vagoneta queda reservado al inicio del proceso
		(at end (occupied ?vag ?equip)) ;El equipaje puede ser descargado una vez está completamente cargado
	)
)

(:durative-action unload_notdanger
	:parameters (
		?equip - equipaje
		?vag - vagoneta
		?maq - maquina
		?loc - localizacion
	)
	:duration (= ?duration (* 1.5 (weight ?equip))) ;La duración es relativa al peso del equipaje
	:condition (and
		(at start (occupied ?vag ?equip))
		(at start (destination ?equip ?loc))
		(over all (at ?maq ?loc)) ;La máquina debe permanecer quieta durante el proceso
		(over all (follow ?vag ?maq)) ;La vagoneta debe seguir unida al tren durante el proceso
		(over all (notdanger ?equip)) ;El equipaje no puede pasar a ser peligroso durante el proceso
	)
	:effect (and 
		(at start (not(destination ?equip ?loc))) ;El equipaje deja de estar disponible para ser cargado
		(at start (not(occupied ?vag ?equip))) ;Protegemos frente acciones que requieran que el equipaje esté dentro de la vagoneta
		(at end	(decrease (elements ?vag) 1)) ;El espacio de la vagoneta que ocupaba el equipaje queda libre al completarse la descarga
		(at end (done ?equip))
	)
)

(:durative-action unload_danger
	:parameters (
		?equip - equipaje
		?vag - vagoneta
		?maq - maquina
	)
	:duration (= ?duration (* 1.5 (weight ?equip))) ;La duración es relativa al peso del equipaje
	:condition (and
		(at start (occupied ?vag ?equip))
		(over all (at ?maq OficinaInspeccion)) ;La máquina debe permanecer quieta durante el proceso
		(over all (follow ?vag ?maq))  ;La vagoneta debe seguir unida al tren durante el proceso
		(over all (danger ?equip)) ;El equipaje no puede pasar a ser seguro durante el proceso
	)
	:effect (and
		(at start (not(occupied ?vag ?equip))) ;Protegemos frente acciones que requieran que el equipaje esté dentro de la vagoneta
		(at end (decrease (elements ?vag) 1)) ;El espacio de la vagoneta que ocupaba el equipaje queda libre al completarse la descarga
		(at end (toanalyce ?equip)) ;El equipaje sólo se puede procesar cuando está totalmente descargado
	)
)

(:durative-action connect
	:parameters (
		?maq - maquina
		?v1 - (either vagoneta maquina)
		?v2 - vagoneta
		?loc - localizacion
	)
	:duration (= ?duration 1) ;La duración es fija y corta
	:condition (and
		(at start (waiting ?v2 ?loc))
		(at start (last ?maq ?v1))
		(over all (at ?maq ?loc)) ;La máquina debe permanecer quieta durante el proceso
		(over all (follow ?v1 ?maq)) ;La penúltima vagoneta debe seguir conectada durante el proceso
	)
	:effect (and 
		(at start (not(waiting ?v2 ?loc))) ;La vagoneta a conectar deja de estar disponible para ser conectada por otra máquina
		(at start (not(last ?maq ?v1))) ;La última vagoneta deja de ser el ultimo eslabón para evitar que otras vagonetas se puedan conectar
		(at end (connected ?v2 ?v1))
		(at end (follow ?v2 ?maq))
		(at end (last ?maq ?v2))
	)
)

(:durative-action disconnect
	:parameters (
		?maq - maquina
		?v1 - (either vagoneta maquina)
		?v2 - vagoneta
		?loc - localizacion
	)
	:duration (= ?duration 1) ;La duración es fija y corta
	:condition (and
		(at start (follow ?v2 ?maq))
		(at start (connected ?v2 ?v1))
		(at start (last ?maq ?v2))
		(over all (at ?maq ?loc))
		(over all (follow ?v1 ?maq)) ;La vagoneta de la que nos vamos a desconectar debe seguir a la máquina durante el proceso
		(over all (>= (elements ?v2) 0)) ;La vagoneta a desconectar debe estar vacía durante todo el proceso
		(over all (<= (elements ?v2) 0))
	)
	:effect (and
		(at start (not(follow ?v2 ?maq))) ;La vagoneta a desconectar deja de estar disponible para otras acciones que la requieran como parte del tren
		(at start (not(connected ?v2 ?v1))) ;La vagoneta a desconectar deja de estar disponible para otras acciones que la requieran como conectada
		(at start (not(last ?maq ?v2))) ;La vagoneta a desconectar deja de ser la última. Durante el proceso no hay "último eslabón"
		(at end (waiting ?v2 ?loc)) ;La vagoneta solo pasa a estar disponible para ser conectada al completarse el proceso
		(at end (last ?maq ?v1)) ;La penúltima vagoneta pasa a ser la última y queda disopnible para recibir conexiones al completarse el proceso
	)
)

(:durative-action analyze
	:parameters (
		?equip - equipaje
	)
	:duration (= ?duration 3)
	:condition (and
		(at start (toanalyce ?equip))
		(at start (danger ?equip))
	)
	:effect (and 
		(at start (not(toanalyce ?equip))) ;El eqipaje se está analizando y no está pendiente de ser analizado
		(at start (not(danger ?equip))) ;Protegemos al paquete de ser requerido por otras acciones como peligroso
		(at end (notdanger ?equip)) ;Solo pasa a ser seguro al completarse el análisis
		(at end (waiting ?equip OficinaInspeccion)) ;El equipaje pasa a estar disponible para ser cargado una vez terminado el proceso
	)
)
)
