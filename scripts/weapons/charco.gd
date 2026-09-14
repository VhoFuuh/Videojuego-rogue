class_name Charco
extends Node2D

# Charco de terremoto: queda en el suelo y va dañando a lo que pase encima.

const INTERVALO := 0.4

var radio := 70.0
var dano := 8
var duracion := 4.0
var color := Color(0.95, 0.82, 0.40)

var _vivido := 0.0
var _espera := 0.0


func _ready() -> void:
	z_index = -2


func _process(delta: float) -> void:
	_vivido += delta
	if _vivido >= duracion:
		queue_free()
		return

	# Se va apagando de a poco para avisar que esta por desaparecer.
	modulate.a = clampf((duracion - _vivido) / 1.2, 0.25, 1.0)

	_espera -= delta
	if _espera > 0.0:
		return
	_espera = INTERVALO
	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		if enemigo.global_position.distance_to(global_position) <= radio:
			enemigo.recibir_dano(dano)


func _draw() -> void:
	draw_colored_polygon(Dibujos.elipse(Vector2.ZERO, radio, radio * 0.55),
		Color(color.r, color.g, color.b, 0.35))
	draw_colored_polygon(Dibujos.elipse(Vector2.ZERO, radio * 0.6, radio * 0.33),
		Color(color.r, color.g, color.b, 0.30))
