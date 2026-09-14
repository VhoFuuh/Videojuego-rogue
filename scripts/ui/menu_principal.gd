extends Node2D

# Pantalla de titulo. Es la escena principal del juego.

const DECORADO := ["quiltro", "moai", "gaviota", "trauco", "ovni"]


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.16, 0.10, 0.11))
	Audio.tocar_musica()
	_construir()


func _draw() -> void:
	var v := get_viewport_rect().size

	# Guirnaldas de fonda en la parte de arriba.
	for i in 26:
		var x := v.x * float(i) / 25.0
		var y := 14.0 + sin(float(i) * 0.9) * 10.0
		var colores := [Color(0.86, 0.24, 0.24), Color(0.96, 0.94, 0.90), Color(0.24, 0.38, 0.78)]
		draw_colored_polygon(PackedVector2Array([
			Vector2(x - 9, y), Vector2(x + 9, y), Vector2(x, y + 24)]),
			colores[i % 3])
	draw_line(Vector2(0, 16), Vector2(v.x, 16), Color(0.55, 0.45, 0.38), 2.0)

	# Fila de personajes abajo.
	var paso := v.x / float(DECORADO.size() + 1)
	for i in DECORADO.size():
		var tipo: String = DECORADO[i]
		var d: Dictionary = Data.ENEMIGOS[tipo]
		draw_set_transform(Vector2(paso * (i + 1), v.y - 95.0), 0.0, Vector2.ONE)
		Dibujos.enemigo(self, tipo, 34.0, d.color, 1.0 if i % 2 == 0 else -1.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _construir() -> void:
	var capa := CanvasLayer.new()
	add_child(capa)

	var raiz := Control.new()
	raiz.set_anchors_preset(Control.PRESET_FULL_RECT)
	raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa.add_child(raiz)

	var columna := Estilo.columna_centrada(14)
	columna.offset_top = -60.0
	raiz.add_child(columna)

	columna.add_child(Estilo.label("FONDA ETERNA", 68, Estilo.DORADO))
	columna.add_child(Estilo.label(
		"Sobrevive de Arica a la Isla de Pascua", 20, Color(0.85, 0.80, 0.74)))

	var espacio := Control.new()
	espacio.custom_minimum_size = Vector2(0, 18)
	columna.add_child(espacio)

	var jugar := Estilo.boton("Jugar")
	jugar.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/main.tscn"))
	columna.add_child(jugar)

	var personajes := Estilo.boton("Personajes  (%s)" % Guardado.personaje_actual().nombre)
	personajes.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/personajes.tscn"))
	columna.add_child(personajes)

	var fonda := Estilo.boton("La fonda  ($ %d)" % Guardado.lucas)
	fonda.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/fonda.tscn"))
	columna.add_child(fonda)

	var logros := Estilo.boton("Logros  (%d/%d)" % [Guardado.logros.size(), Data.LOGROS.size()])
	logros.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/logros.tscn"))
	columna.add_child(logros)

	var opciones := Estilo.boton("Opciones")
	opciones.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/opciones.tscn"))
	columna.add_child(opciones)

	var salir := Estilo.boton("Salir")
	salir.pressed.connect(func() -> void: get_tree().quit())
	columna.add_child(salir)

	if Guardado.partidas > 0:
		columna.add_child(Estilo.label(_resumen(), 17, Color(0.78, 0.74, 0.70)))

	jugar.call_deferred("grab_focus")


func _resumen() -> String:
	return "Mejor marca: %d:%02d  ·  nivel %d  ·  %d jefes  ·  %d partidas" % [
		int(Guardado.mejor_tiempo) / 60, int(Guardado.mejor_tiempo) % 60,
		Guardado.mejor_nivel, Guardado.jefes_derrotados, Guardado.partidas]
