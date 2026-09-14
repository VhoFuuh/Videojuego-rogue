extends Node2D

# Muestra todos los personajes juntos y grandes para revisar los diseños.
# Uso: godot --path . res://pruebas/galeria.tscn

const R := 42.0
const COLUMNAS := 4
const PASO := Vector2(300, 230)
const ORIGEN := Vector2(160, 150)


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.16, 0.14, 0.18))
	await get_tree().process_frame
	await _capturar()
	get_tree().quit()


func _draw() -> void:
	var fuente := ThemeDB.fallback_font
	var indice := 0

	_celda(fuente, ORIGEN, "Huaso (jugador)")
	Dibujos.huaso(self, R, Color(0.90, 0.76, 0.60), Vector2.RIGHT)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	indice += 1

	for tipo in Data.ENEMIGOS:
		var d: Dictionary = Data.ENEMIGOS[tipo]
		var pos := ORIGEN + Vector2(
			PASO.x * (indice % COLUMNAS), PASO.y * (indice / COLUMNAS))
		_celda(fuente, pos, d.nombre)
		Dibujos.enemigo(self, tipo, R, d.color, 1.0)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		indice += 1


func _celda(fuente: Font, pos: Vector2, titulo: String) -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_string(fuente, pos + Vector2(-120, 95), titulo,
		HORIZONTAL_ALIGNMENT_CENTER, 240, 18, Color(0.92, 0.90, 0.88))
	draw_set_transform(pos, 0.0, Vector2.ONE)


func _capturar() -> void:
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("user://capturas")
	var imagen := get_viewport().get_texture().get_image()
	imagen.save_png("user://capturas/galeria.png")
	print("galeria: ", ProjectSettings.globalize_path("user://capturas/galeria.png"))
