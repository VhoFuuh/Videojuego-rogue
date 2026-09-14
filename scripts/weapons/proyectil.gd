class_name Proyectil
extends Node2D

const RADIO_IMPACTO := 14.0
const VIDA_MAXIMA := 2.0

var direccion := Vector2.RIGHT
var velocidad := 560.0
var dano := 10
var perforacion := 1

var _tiempo := 0.0
var _golpeados := {}


func _ready() -> void:
	add_to_group("proyectiles")


func _process(delta: float) -> void:
	_tiempo += delta
	if _tiempo > VIDA_MAXIMA:
		queue_free()
		return

	global_position += direccion * velocidad * delta
	rotation = direccion.angle()

	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		if _golpeados.has(enemigo.get_instance_id()):
			continue
		if global_position.distance_to(enemigo.global_position) <= RADIO_IMPACTO + enemigo.radio:
			_golpeados[enemigo.get_instance_id()] = true
			enemigo.recibir_dano(dano)
			perforacion -= 1
			if perforacion <= 0:
				queue_free()
				return


func _draw() -> void:
	# Anticucho: palito con fuego.
	draw_line(Vector2(-10, 0), Vector2(10, 0), Color(0.75, 0.55, 0.35), 3.0)
	draw_circle(Vector2(8, 0), 5.0, Color(1.0, 0.55, 0.15))
	draw_circle(Vector2(8, 0), 2.5, Color(1.0, 0.90, 0.55))
