(define (domain ej3_dominio_aeropuerto_renovable)

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
	(adyacent ?loc1 - localizacion, ?loc2 - localizacion) 
	(at ?maq - maquina ?loc - localizacion)
	(connected ?vag - vagoneta ?v - (either vagoneta maquina))
	(follow ?v - (either vagoneta maquina) ?maq - maquina)
	(last ?maq - maquina ?v - (either vagoneta maquina))
	(occupied ?vag - vagoneta ?eq - equipaje)
	(danger ?eq - equipaje)
	(notdanger ?eq - equipaje)
	(destination ?eq - equipaje ?loc - localizacion)
	(waiting ?x - (either equipaje vagoneta) ?loc - localizacion)
	(toanalyce ?eq - equipaje)
    (done ?eq - equipaje)
)

(:functions
	(distance ?l1 - localizacion ?l2 - localizacion)
	(speed ?maq - maquina)
	(capacity ?vag - vagoneta)
	(elements ?vag - vagoneta)
	(weight ?eq - equipaje)
	
	(max-fuel ?maq - maquina) ;Máximo combustible que puede tener una máquina	
	(fuel ?maq - maquina) ;Combustible actual de una máquina
	(burn ?maq - maquina) ;Gasto de combustible de una máquina por unidad de distancia	
	(total-fuel-used) ;Combustible total gastado
	(refuel-duration) ;Tiempo requerido para cargar una unidad de combustible dentro de una máquina
)

(:durative-action move
	:parameters (
		?maq - maquina
		?orig - localizacion
		?dest - localizacion
	)
	:duration (= ?duration (/ (distance ?orig ?dest) (speed ?maq)))
	:condition (and
		(at start (at ?maq ?orig))
		(at start (>= (fuel ?maq) (* (distance ?orig ?dest) (burn ?maq)))) ;La máquina debe tener suficiente combustible como para llegar al destino
		(over all (adyacent ?orig ?dest))
	)
	:effect (and 
		(at start (not (at ?maq ?orig)))
		(at end (at ?maq ?dest))
		(at end (decrease (fuel ?maq) (* (distance ?orig ?dest) (burn ?maq)))) ;El combustible consumido se resta al depósito de la máquina
		(at end (increase (total-fuel-used) (* (distance ?orig ?dest) (burn ?maq)))) ;El combustible consumido se suma al consumo total
	)
)

(:durative-action load
	:parameters (
		?eq - equipaje
		?vag - vagoneta
		?maq - maquina
		?loc - localizacion
	)
	:duration (= ?duration (* 1.5 (weight ?eq)))
	:condition (and
		(at start (waiting ?eq ?loc))
		(at start (> (capacity ?vag) (elements ?vag)))
		(over all (at ?maq ?loc))
		(over all (follow ?vag ?maq))
	)
	:effect (and 
		(at start (not(waiting ?eq ?loc)))
		(at start (increase (elements ?vag) 1))
		(at end (occupied ?vag ?eq))
	)
)

(:durative-action unload_notdanger
	:parameters (
		?eq - equipaje
		?vag - vagoneta
		?maq - maquina
		?loc - localizacion
	)
	:duration (= ?duration (* 1.5 (weight ?eq)))
	:condition (and
		(at start (occupied ?vag ?eq))
		(at start (destination ?eq ?loc))
		(over all (at ?maq ?loc))
		(over all (notdanger ?eq))
		(over all (follow ?vag ?maq))
	)
	:effect (and 
		(at start (not(destination ?eq ?loc)))
		(at start (not(occupied ?vag ?eq)))
		(at end	(decrease (elements ?vag) 1))
		(at end	(done ?eq))
	)
)

(:durative-action unload_danger
	:parameters (
		?eq - equipaje
		?vag - vagoneta
		?maq - maquina
	)
	:duration (= ?duration (* 1.5 (weight ?eq)))
	:condition (and
		(at start (occupied ?vag ?eq))
		(over all (at ?maq OficinaInspeccion))
		(over all (follow ?vag ?maq))
		(over all (danger ?eq))
	)
	:effect (and
		(at start (not(occupied ?vag ?eq)))
		(at end (decrease (elements ?vag) 1))
		(at end (toanalyce ?eq))
	)
)

(:durative-action connect
	:parameters (
		?maq - maquina
		?v1 - (either vagoneta maquina)
		?v2 - vagoneta
		?loc - localizacion
	)
	:duration (= ?duration 1)
	:condition (and
		(at start (waiting ?v2 ?loc))
		(at start (last ?maq ?v1))
		(over all (at ?maq ?loc))
		(over all (follow ?v1 ?maq))
	)
	:effect (and 
		(at start (not(waiting ?v2 ?loc)))
		(at start (not(last ?maq ?v1)))
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
	:duration (= ?duration 1)
	:condition (and
		(at start (follow ?v2 ?maq))
		(at start (connected ?v2 ?v1))
		(at start (last ?maq ?v2))
		(over all (at ?maq ?loc))
		(over all (follow ?v1 ?maq))
		(over all (>= (elements ?v2) 0))
		(over all (<= (elements ?v2) 0))
	)
	:effect (and
		(at start (not(follow ?v2 ?maq)))
		(at start (not(connected ?v2 ?v1)))
		(at start (not(last ?maq ?v2)))
		(at end (waiting ?v2 ?loc))
		(at end (last ?maq ?v1))
	)
)

(:durative-action analyze
	:parameters (
		?eq - equipaje
	)
	:duration (= ?duration 3)
	:condition (and
		(at start (toanalyce ?eq))
		(at start (danger ?eq))
	)
	:effect (and 
		(at start (not(toanalyce ?eq)))
		(at start (not(danger ?eq)))
		(at end (notdanger ?eq))
		(at end (waiting ?eq OficinaInspeccion))
	)
)

(:durative-action refuel
	:parameters (
		?maq - maquina
		?loc - localizacion
	)
	:duration (= ?duration (* (- (max-fuel ?maq) (fuel ?maq)) (refuel-duration))) ;El tiempo empleado dependerá del combustible que haya que repostar
	:condition (and
		(at start (>= (/ (max-fuel ?maq) 2) (fuel ?maq))) ;Sólo puede recargar cuando tiene menos de la mitad del combustible
		(over all (at ?maq ?loc)) ;Mientras la máquina está repostando no se puede mover
	)
	:effect (and 
		(at end (assign (fuel ?maq) (max-fuel ?maq))) ;La máquina estará a su máxima capacidad de combustible
	)
)
)