class_name OrbeXP
extends Node2D

var valor := 1

var _jugador: Player
var _velocidad := 0.0


func _ready() -> void:
	_jugador = get_tree().get_first_node_in_group("jugador") as Player


func _process(delta: float) -> void:
	if _jugador == null or not is_instance_valid(_jugador):
		return

	var hacia: Vector2 = _jugador.global_position - global_position
	var distancia := hacia.length()

	# Los que quedaron lejisimos ya no se van a recoger: se eliminan para no
	# acumular miles de nodos durante una partida larga.
	if distancia > 1800.0:
		queue_free()
		return

	if distancia <= _jugador.radio_recogida:
		# Se acelera mientras se acerca: se siente mucho mejor que velocidad fija.
		_velocidad = min(_velocidad + 900.0 * delta, 700.0)
		global_position += hacia.normalized() * _velocidad * delta
	else:
		_velocidad = 0.0

	if distancia <= 16.0:
		_jugador.ganar_xp(valor)
		queue_free()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 5.0, Color(0.45, 0.90, 0.55))
	draw_circle(Vector2.ZERO, 2.5, Color(0.85, 1.0, 0.90))
