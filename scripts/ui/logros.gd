extends Node2D

# Lista de logros con su progreso. Sirve de guia de que hacer despues.


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.14, 0.12, 0.15))
	Audio.tocar_musica()
	_construir()


func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _construir() -> void:
	var capa := CanvasLayer.new()
	add_child(capa)

	var margen := MarginContainer.new()
	margen.set_anchors_preset(Control.PRESET_FULL_RECT)
	margen.add_theme_constant_override("margin_left", 60)
	margen.add_theme_constant_override("margin_right", 60)
	margen.add_theme_constant_override("margin_top", 18)
	margen.add_theme_constant_override("margin_bottom", 18)
	capa.add_child(margen)

	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 8)
	margen.add_child(columna)

	var hechos := Guardado.logros.size()
	columna.add_child(Estilo.label("LOGROS", 40, Estilo.DORADO))
	columna.add_child(Estilo.label(
		"%d de %d conseguidos" % [hechos, Data.LOGROS.size()], 18,
		Color(0.82, 0.78, 0.74)))

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	columna.add_child(scroll)

	var lista := VBoxContainer.new()
	lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lista.add_theme_constant_override("separation", 5)
	scroll.add_child(lista)

	for l in Data.LOGROS:
		lista.add_child(_fila(l))

	var volver := Estilo.boton("Volver  (ESC)", 260.0)
	volver.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/menu.tscn"))
	var centrado := HBoxContainer.new()
	centrado.alignment = BoxContainer.ALIGNMENT_CENTER
	centrado.add_child(volver)
	columna.add_child(centrado)


func _fila(l: Dictionary) -> PanelContainer:
	var hecho := Guardado.tiene_logro(str(l.id))
	var valor := Guardado.valor_de(str(l.campo))
	var meta := float(l.meta)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", Estilo.caja(
		Color(0.22, 0.18, 0.13) if hecho else Color(0.17, 0.15, 0.17),
		Estilo.DORADO if hecho else Color(0.30, 0.26, 0.28), 6, 5))

	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 12)
	panel.add_child(fila)

	var marca := Estilo.label("*" if hecho else "-", 26,
		Estilo.DORADO if hecho else Color(0.40, 0.37, 0.38))
	marca.custom_minimum_size = Vector2(26, 0)
	fila.add_child(marca)

	var texto := VBoxContainer.new()
	texto.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texto.add_theme_constant_override("separation", 1)
	fila.add_child(texto)

	var titulo := Estilo.label(l.nombre, 19,
		Estilo.CREMA if hecho else Color(0.72, 0.69, 0.68))
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	texto.add_child(titulo)

	var desc := Estilo.label(l.desc, 14, Color(0.76, 0.72, 0.69))
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	texto.add_child(desc)

	# El progreso del tiempo se muestra en minutos, no en segundos sueltos.
	var progreso: String
	if str(l.campo) == "mejor_tiempo":
		progreso = "%d:%02d / %d:%02d" % [
			int(valor) / 60, int(valor) % 60, int(meta) / 60, int(meta) % 60]
	else:
		progreso = "%d / %d" % [int(min(valor, meta)), int(meta)]
	fila.add_child(Estilo.label(progreso, 16, Color(0.80, 0.76, 0.72)))

	fila.add_child(Estilo.label("+$ %d" % int(l.premio), 16, Estilo.DORADO))
	return panel
