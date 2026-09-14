class_name MicroBus
extends Node2D

# La micro: cruza la pantalla de lado a lado atropellando todo lo que pilla.

const INTERVALO_ATROPELLO := 0.25

var direccion := Vector2.RIGHT
var velocidad := 620.0
var dano := 60
var largo := 92.0
var alto := 54.0
var color := Color(0.95, 0.78, 0.18)

var _vivido := 0.0
var _espera := 0.0
var _golpeados := {}


func _ready() -> void:
	z_index = 2
	rotation = direccion.angle()


func _process(delta: float) -> void:
	_vivido += delta
	if _vivido > 4.0:
		queue_free()
		return

	global_position += direccion * velocidad * delta

	_espera -= delta
	if _espera > 0.0:
		return
	_espera = INTERVALO_ATROPELLO

	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		var local: Vector2 = (enemigo.global_position - global_position).rotated(-rotation)
		if absf(local.x) <= largo * 0.6 and absf(local.y) <= alto * 0.8:
			var id := enemigo.get_instance_id()
			# Un enemigo no puede ser atropellado dos veces por la misma micro.
			if not _golpeados.has(id):
				_golpeados[id] = true
				enemigo.recibir_dano(dano)


func _draw() -> void:
	var l := largo * 0.5
	var a := alto * 0.5
	draw_colored_polygon(Dibujos.elipse(Vector2(0, a + 6), l * 0.9, 7.0), Color(0, 0, 0, 0.25))

	# Carroceria.
	Dibujos.figura(self, PackedVector2Array([
		Vector2(-l, -a * 0.6), Vector2(l * 0.72, -a),
		Vector2(l, -a * 0.2), Vector2(l, a), Vector2(-l, a)]), color, 2.0)
	# Ventanas.
	for i in 3:
		var x := -l * 0.72 + i * l * 0.52
		draw_rect(Rect2(x, -a * 0.5, l * 0.38, a * 0.55), Color(0.35, 0.55, 0.65))
	# Franja y ruedas.
	draw_line(Vector2(-l, a * 0.35), Vector2(l, a * 0.35), color.darkened(0.35), 3.0)
	draw_circle(Vector2(-l * 0.55, a), 8.0, Color(0.14, 0.13, 0.14))
	draw_circle(Vector2(l * 0.58, a), 8.0, Color(0.14, 0.13, 0.14))
