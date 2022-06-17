(define (domain ej1_dominio_aeropuerto)

(:requirements :strips :typing :equality)

(:types
    numero
	localizacion
	equipaje
	vagoneta
	maquina
)

(:constants
    OficinaInspeccion - localizacion
	zero - numero
)

(:predicates
	(adyacent ?loc1 - localizacion, ?loc2 - localizacion)  ;Una localización es adyacente a otra
	(at ?maq - maquina ?loc - localizacion) ;Una máquina se encuentra en una localización
	(connected ?vag - vagoneta ?v - (either vagoneta maquina)) ;Una vagoneta (?vag) sigue a otro vehículo (?v)
	(follow ?v - (either vagoneta maquina) ?maq - maquina) ;Un vehículo (?v) pertenece al tren que dirige una máquina
	(last ?maq - maquina ?v - (either vagoneta maquina)) ;Un vehículo (?v) es el último eslabón del tren que dirige una máquina
	(occupied ?vag - vagoneta ?eq - equipaje) ;Un equipaje ocupa un espacio dentro de una vagoneta
	(danger ?eq - equipaje) ;Un equipaje es seguro
	(notdanger ?eq - equipaje) ;Un equipaje es peligroso
	(destination ?eq - equipaje ?loc - localizacion) ;Destino al que debe ser llevado un equipaje
	(waiting ?x - (either equipaje vagoneta) ?loc - localizacion) ;Un equipaje o vagoneta (?x) espera a ser recogido en una localización
	(toanalyce ?eq - equipaje) ;Un equipaje sospechoso está en la OficinaInspeccion para ser analizado
    (done ?eq - equipaje) ;Un equipaje ha llegado a su destino y no es sospechoso
	(next ?n1 - numero ?n2 - numero) ;Orden entre números siendo ?n1 menor que ?n2
	(carried ?vag - vagoneta ?n - numero) ;Cantidad de equipaje cargado por una vagoneta
)

(:action move
	:parameters (
		?maq - maquina
		?orig - localizacion
		?dest - localizacion
	)
	:precondition (and
		(at ?maq ?orig) ;La máquina debe estar en el origen
		(adyacent ?orig ?dest) ;El origen y el destino deben ser adyacentes
	)
	:effect (and 
		(not (at ?maq ?orig)) ;La máquina dejará de estar en el origen
		(at ?maq ?dest) ;La máquina estará en el destino
	)
)

(:action load
	:parameters (
		?eq - equipaje
		?vag - vagoneta
		?maq - maquina
		?quant - numero
		?upperQuant - numero
		?loc - localizacion
	)
	:precondition (and
		(at ?maq ?loc) ;La máquina debe encontrarse en la misma localización que el equipaje
		(follow ?vag ?maq) ;La vagoneta en la que se cargará el equipaje debe seguir a la máquina
		(waiting ?eq ?loc) ;El equipaje a cargar debe estar a la espera de ser cargado (fuera de cualquier vagoneta)
		(carried ?vag ?quant) ;Debe existir un número superior al número de equipajes cargados en la vagoneta
		(next ?quant ?upperQuant)
	)
	:effect (and 
		(not(waiting ?eq ?loc)) ;El equipaje dejará de estar a la espera de ser cargado
		(occupied ?vag ?eq) ;El equipaje pasará a estar dentro de la vagoneta
		(not(carried ?vag ?quant)) ;La cantidad de equipajes en la vagoneta pasará a ser el número superior
		(carried ?vag ?upperQuant)

	)
)

(:action unload_notdanger
	:parameters (
		?eq - equipaje
		?vag - vagoneta
		?maq - maquina
		?quant - numero
		?lowerQuant - numero
		?loc - localizacion
	)
	:precondition (and
        (notdanger ?eq) ;El equipaje debe ser seguro
        (destination ?eq ?loc) ;El destino del equipaje debe ser la localización en la que estamos
		(at ?maq ?loc) ;La máquina también se debe encontrar en esa localización
		(follow ?vag ?maq) ;La vagoneta que contiene al equipaje debe seguir a la máquina
		(occupied ?vag ?eq) ;El equipaje debe estar cargado en la vagoneta
		(carried ?vag ?quant) ;Debe existir un número inferior al número de equipajes cargados en la vagoneta
		(next ?lowerQuant ?quant)
	)
	:effect (and 
		(done ?eq) ;El equipaje se marcará como entregado
        (not(destination ?eq ?loc)) ;El equipaje ya no tendrá un destino
		(not(occupied ?vag ?eq)) ;El equipaje ya no estará en la vagoneta
		(not(carried ?vag ?quant)) ;La cantidad de equipajes en la vagoneta pasará a ser el número inferior
		(carried ?vag ?lowerQuant)
	)
)

(:action unload_danger
	:parameters (
		?eq - equipaje
		?vag - vagoneta
		?maq - maquina
		?quant - numero
		?lowerQuant - numero
		?loc - localizacion
	)
	:precondition (and
        (danger ?eq) ;El equipaje debe ser peligroso
        (= ?loc OficinaInspeccion) ;Debemos estar en la oficina de inspección
		(at ?maq ?loc) ;La máquina también se debe encontrar en esa localización
		(follow ?vag ?maq) ;La vagoneta que contiene al equipaje debe seguir a la máquina
		(occupied ?vag ?eq) ;El equipaje debe estar cargado en la vagoneta
		(carried ?vag ?quant) ;Debe existir un número inferior al número de equipajes cargados en la vagoneta
		(next ?lowerQuant ?quant)
	)
	:effect (and
        (toanalyce ?eq) ;El equipaje se marcará como pendiente de ser analizado
		(not(occupied ?vag ?eq)) ;El equipaje ya no estará en la vagoneta
		(not(carried ?vag ?quant))  ;La cantidad de equipajes en la vagoneta pasará a ser el número inferior
		(carried ?vag ?lowerQuant)
	)
)

(:action connect
	:parameters (
		?maq - maquina
		?v1 - (either vagoneta maquina)
		?v2 - vagoneta
		?loc - localizacion
	)
	:precondition (and
		(waiting ?v2 ?loc) ;La vagoneta está suelta y a la espera de ser conectada en una localización
		(at ?maq ?loc) ;La máquina también se debe encontrar en esa localización
		(follow ?v1 ?maq) ;El último eslabón conectado sigue a la máquina
		(last ?maq ?v1) ;El último eslabón es realmente el último eslabón
	)
	:effect (and 
		(not(waiting ?v2 ?loc)) ;La vagoneta deja de estar a la espera de ser conectada
		(follow ?v2 ?maq) ;La vagoneta pasará a aseguir también a la máquina
		(connected ?v2 ?v1) ;La vagoneta pasará a estar conectada detras el que era antes el último eslabón
		(not(last ?maq ?v1)) ;La vagoneta pasará a ser ahora el último eslabón del tren que dirige la máquina
		(last ?maq ?v2)
	)
)

(:action disconnect
	:parameters (
		?maq - maquina
		?v1 - (either vagoneta maquina)
		?v2 - vagoneta
		?quant - numero
		?loc - localizacion
	)
	:precondition (and
		(at ?maq ?loc) ;La máquina se encuentra en una cierta localización
		(follow ?v1 ?maq) ;El penúltimo eslabón sigue a la máquina
		(follow ?v2 ?maq) ;El último eslabón sigue a la máquina
		(connected ?v2 ?v1) ;Los eslabones último y penúltimo están conectados
		(last ?maq ?v2) ;El último eslabón es realmente el último eslabón
		(carried ?v2 zero) ;La cantidad de equipajes cargados en el último eslabón es cero
		(= ?quant zero)
	)
	:effect (and 
		(waiting ?v2 ?loc) ;La vagoneta pasará a estar suelta y a la espera de ser conectada en esa localización
		(not(follow ?v2 ?maq)) ;La vagoneta dejará de seguir a la máquina
		(not(connected ?v2 ?v1)) ;La vagoneta dejará de estar conectada al que era el penúltimo eslabón
		(not(last ?maq ?v2)) ;El que era el penúltimo eslabón pasará a ser el último
		(last ?maq ?v1)
	)
)

(:action analyze
	:parameters (
		?eq - equipaje
	)
	:precondition (and
		(toanalyce ?eq) ;El equiaje debe estar marcado como pendiente de ser analizado
		(danger ?eq) ;El equipaje debe ser peligroso
	)
	:effect (and 
		(not(danger ?eq)) ;El equipaje deja de ser peligroso
		(notdanger ?eq) ;El equipaje pasa a ser seguro
        (not(toanalyce ?eq)) ;El equipaje deja de estar epndiente de ser analizado
        (waiting ?eq OficinaInspeccion) ;El equipaje pasa a estar disponible para ser cargado en la oficina
	)
)
)