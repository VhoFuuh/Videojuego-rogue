class_name Arma
extends Node2D

# Base de todas las armas. Cada una sube hasta MAX_NIVEL y ahi puede
# evolucionar si el jugador tambien tiene al maximo la pasiva que le toca.

const MAX_NIVEL := 5

var nivel := 1
var evolucionada := false

var _jugador: Player


func _ready() -> void:
	_jugador = get_parent() as Player
	iniciar()


# Cada arma pone aca lo suyo en vez de sobreescribir _ready.
func iniciar() -> void:
	pass


func subir_nivel() -> void:
	nivel = mini(nivel + 1, MAX_NIVEL)


func al_maximo() -> bool:
	return nivel >= MAX_NIVEL


func evolucionar() -> void:
	evolucionada = true


# Atajo: casi todas las armas escalan su daño con el multiplicador del jugador.
func golpe(base: int) -> int:
	return int(base * _jugador.mult_dano)


func enemigos() -> Array:
	return get_tree().get_nodes_in_group("enemigos")


func enemigo_mas_cercano(alcance: float) -> Node2D:
	var mejor: Node2D = null
	var mejor_distancia := alcance
	for enemigo in enemigos():
		var d: float = _jugador.global_position.distance_to(enemigo.global_position)
		if d < mejor_distancia:
			mejor_distancia = d
			mejor = enemigo
	return mejor


# Los proyectiles y charcos viven en la escena del juego, no colgando del
# jugador: si colgaran de el, se moverian con el.
func mundo() -> Node:
	return _jugador.get_parent()
