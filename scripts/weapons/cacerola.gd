extends Node2D

# Cacerolazo: cada cierto tiempo golpea a todos los enemigos alrededor.
# Es el arma inicial, no hay que apuntar.

var nivel := 1

var _espera := 0.0
var _animacion := 0.0
var _jugador: Player


func _ready() -> void:
	_jugador = get_parent() as Player
	z_index = -1


func _process(delta: float) -> void:
	if _jugador == null:
		return

	_espera -= delta * _jugador.mult_vel_ataque
	if _espera <= 0.0:
		_espera = intervalo()
		_golpear()

	if _animacion > 0.0:
		_animacion -= delta * 3.0
		queue_redraw()


func radio() -> float:
	return 100.0 + nivel * 22.0


func dano() -> int:
	return 10 + nivel * 6


func intervalo() -> float:
	return 1.1


func _golpear() -> void:
	_animacion = 1.0
	var golpe := int(dano() * _jugador.mult_dano)
	var r := radio()
	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		if enemigo.global_position.distance_to(_jugador.global_position) <= r:
			enemigo.recibir_dano(golpe)
	queue_redraw()


func _draw() -> void:
	if _animacion <= 0.0:
		return
	# Onda que se expande al golpear.
	var t := 1.0 - _animacion
	var c := Color(0.85, 0.85, 0.90, _animacion * 0.7)
	draw_arc(Vector2.ZERO, radio() * t, 0.0, TAU, 48, c, 3.0)
