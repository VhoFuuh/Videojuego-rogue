extends Node2D

# La fonda: tienda de mejoras permanentes que se compran entre partidas.

var _lbl_lucas: Label
var _filas: VBoxContainer


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.18, 0.12, 0.10))
	Audio.tocar_musica()
	_construir()
	_refrescar()


func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _construir() -> void:
	var capa := CanvasLayer.new()
	add_child(capa)

	var margen := MarginContainer.new()
	margen.set_anchors_preset(Control.PRESET_FULL_RECT)
	margen.add_theme_constant_override("margin_left", 40)
	margen.add_theme_constant_override("margin_right", 40)
	margen.add_theme_constant_override("margin_top", 24)
	margen.add_theme_constant_override("margin_bottom", 24)
	capa.add_child(margen)

	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 10)
	margen.add_child(columna)

	columna.add_child(Estilo.label("LA FONDA", 44, Estilo.DORADO))
	columna.add_child(Estilo.label(
		"Mejoras que te quedan para siempre", 17, Color(0.82, 0.77, 0.72)))

	_lbl_lucas = Estilo.label("", 24, Estilo.DORADO)
	columna.add_child(_lbl_lucas)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	columna.add_child(scroll)

	_filas = VBoxContainer.new()
	_filas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_filas.add_theme_constant_override("separation", 8)
	scroll.add_child(_filas)

	var volver := Estilo.boton("Volver  (ESC)", 260.0)
	volver.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/menu.tscn"))
	var centrado := HBoxContainer.new()
	centrado.alignment = BoxContainer.ALIGNMENT_CENTER
	centrado.add_child(volver)
	columna.add_child(centrado)


func _refrescar() -> void:
	_lbl_lucas.text = "Tienes $ %d lucas" % Guardado.lucas

	for hijo in _filas.get_children():
		_filas.remove_child(hijo)
		hijo.queue_free()

	for mejora in Data.PERMANENTES:
		_filas.add_child(_fila(mejora))


func _fila(mejora: Dictionary) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel",
		Estilo.caja(Color(0.20, 0.15, 0.15), Color(0.34, 0.26, 0.25), 6, 5))

	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 14)
	panel.add_child(fila)

	var nivel := Guardado.nivel_de(mejora.id)
	var maximo := int(mejora.max)

	var icono := ColorRect.new()
	icono.color = mejora.color
	icono.custom_minimum_size = Vector2(10, 44)
	fila.add_child(icono)

	var texto := VBoxContainer.new()
	texto.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texto.add_theme_constant_override("separation", 2)
	fila.add_child(texto)

	var titulo := Estilo.label("%s   [%d/%d]" % [mejora.nombre, nivel, maximo], 20)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	texto.add_child(titulo)

	var desc := Estilo.label(mejora.desc, 15, Color(0.80, 0.75, 0.71))
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	texto.add_child(desc)

	# Puntitos que muestran el progreso de un vistazo.
	var puntos := HBoxContainer.new()
	puntos.add_theme_constant_override("separation", 4)
	puntos.alignment = BoxContainer.ALIGNMENT_CENTER
	for i in maximo:
		var p := ColorRect.new()
		p.custom_minimum_size = Vector2(14, 14)
		p.color = mejora.color if i < nivel else Color(0.30, 0.26, 0.26)
		puntos.add_child(p)
	fila.add_child(puntos)

	var boton: Button
	if Guardado.al_maximo(mejora):
		boton = Estilo.boton("Al maximo", 190.0)
		boton.disabled = true
	else:
		var costo := Guardado.costo_de(mejora)
		boton = Estilo.boton("Comprar  $ %d" % costo, 190.0)
		boton.disabled = Guardado.lucas < costo
		boton.pressed.connect(func() -> void:
			if Guardado.comprar(mejora):
				Audio.sonar("nivel")
				_refrescar())
	fila.add_child(boton)

	return panel
