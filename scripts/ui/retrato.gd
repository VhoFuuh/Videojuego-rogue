class_name Retrato
extends Control

# Dibuja un personaje dentro de un contenedor de interfaz.

var id := "huaso"
var radio := 34.0
var apagado := false


func _ready() -> void:
	custom_minimum_size = Vector2(0, radio * 2.8)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	# Dibujos trabaja alrededor del origen, asi que se mueve al centro del area.
	draw_set_transform(Vector2(size.x * 0.5, size.y * 0.62), 0.0, Vector2.ONE)
	draw_colored_polygon(
		Dibujos.elipse(Vector2(0, radio * 1.05), radio * 0.9, radio * 0.28),
		Color(0, 0, 0, 0.25))
	var piel := Color(0.90, 0.76, 0.60)
	if apagado:
		piel = Color(0.35, 0.33, 0.34)
	Dibujos.personaje(self, id, radio, piel, Vector2.RIGHT)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if apagado:
		# Los bloqueados se ven en sombra para que igual se note quienes son.
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.10, 0.08, 0.10, 0.55))
