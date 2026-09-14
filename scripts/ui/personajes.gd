extends Node2D

# Seleccion de personaje. Cada uno cambia el arma inicial y las estadisticas,
# asi que elegir distinto es empezar una partida distinta.

var _lbl_lucas: Label
var _fila: HBoxContainer


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.15, 0.12, 0.16))
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
	margen.add_theme_constant_override("margin_left", 30)
	margen.add_theme_constant_override("margin_right", 30)
	margen.add_theme_constant_override("margin_top", 20)
	margen.add_theme_constant_override("margin_bottom", 20)
	capa.add_child(margen)

	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 10)
	margen.add_child(columna)

	columna.add_child(Estilo.label("ELIGE TU PERSONAJE", 40, Estilo.DORADO))
	_lbl_lucas = Estilo.label("", 20, Estilo.DORADO)
	columna.add_child(_lbl_lucas)

	_fila = HBoxContainer.new()
	_fila.add_theme_constant_override("separation", 14)
	_fila.alignment = BoxContainer.ALIGNMENT_CENTER
	_fila.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columna.add_child(_fila)

	var volver := Estilo.boton("Volver  (ESC)", 260.0)
	volver.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/menu.tscn"))
	var centrado := HBoxContainer.new()
	centrado.alignment = BoxContainer.ALIGNMENT_CENTER
	centrado.add_child(volver)
	columna.add_child(centrado)


func _refrescar() -> void:
	_lbl_lucas.text = "Tienes $ %d lucas" % Guardado.lucas
	for hijo in _fila.get_children():
		_fila.remove_child(hijo)
		hijo.queue_free()
	for p in Data.PERSONAJES:
		_fila.add_child(_carta(p))


func _carta(p: Dictionary) -> PanelContainer:
	var desbloqueado := Guardado.tiene_personaje(p.id)
	var elegido: bool = Guardado.personaje == p.id

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(268, 0)
	panel.add_theme_stylebox_override("panel", Estilo.caja(
		Color(0.21, 0.16, 0.18) if elegido else Color(0.17, 0.14, 0.16),
		Estilo.DORADO if elegido else Color(0.32, 0.26, 0.27), 8, 10))

	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 6)
	panel.add_child(columna)

	var retrato := Retrato.new()
	retrato.id = p.id
	retrato.apagado = not desbloqueado
	columna.add_child(retrato)

	columna.add_child(Estilo.label(p.nombre, 22, p.color))

	var desc := Estilo.label(p.desc, 14, Color(0.82, 0.78, 0.74))
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size = Vector2(0, 52)
	columna.add_child(desc)

	var nombres := []
	for id in p.armas:
		nombres.append(str(Data.ARMAS[id].nombre))
	var color_arma: Color = Data.ARMAS[p.armas[0]].color
	columna.add_child(Estilo.label(
		"Empieza con: %s" % " + ".join(nombres), 13, color_arma))
	columna.add_child(Estilo.label(_resumen(p), 13, Color(0.74, 0.72, 0.70)))

	var boton: Button
	if not desbloqueado:
		boton = Estilo.boton("Desbloquear  $ %d" % int(p.costo), 230.0)
		boton.disabled = Guardado.lucas < int(p.costo)
		boton.pressed.connect(func() -> void:
			if Guardado.desbloquear_personaje(p):
				Audio.sonar("nivel")
				Guardado.elegir_personaje(p.id)
				_refrescar())
	elif elegido:
		boton = Estilo.boton("Elegido", 230.0)
		boton.disabled = true
	else:
		boton = Estilo.boton("Elegir", 230.0)
		boton.pressed.connect(func() -> void:
			Guardado.elegir_personaje(p.id)
			Audio.sonar("xp")
			_refrescar())
	columna.add_child(boton)

	return panel


func _resumen(p: Dictionary) -> String:
	# Se muestran solo las diferencias contra el personaje base.
	var partes := []
	for campo in [["vida", "vida"], ["velocidad", "vel"], ["dano", "daño"],
			["vel_ataque", "ataque"]]:
		var v := float(p[campo[0]])
		if not is_equal_approx(v, 1.0):
			partes.append("%s %+d%%" % [campo[1], int(round((v - 1.0) * 100.0))])
	if float(p.get("regen", 0.0)) > 0.0:
		partes.append("regenera vida")
	return "  ·  ".join(partes) if not partes.is_empty() else "sin bonus ni castigo"
