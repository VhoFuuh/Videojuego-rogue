extends Node2D

# Opciones: volumen, pantalla completa y borrado del progreso.

var _confirmando := false
var _boton_borrar: Button


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

	var raiz := Control.new()
	raiz.set_anchors_preset(Control.PRESET_FULL_RECT)
	raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa.add_child(raiz)

	var columna := Estilo.columna_centrada(14)
	raiz.add_child(columna)

	columna.add_child(Estilo.label("OPCIONES", 42, Estilo.DORADO))

	columna.add_child(_deslizador("Musica", Guardado.volumen_musica,
		func(v: float) -> void:
			Guardado.volumen_musica = v
			Audio.volumen_musica = v
			Guardado.guardar()))

	columna.add_child(_deslizador("Efectos", Guardado.volumen_efectos,
		func(v: float) -> void:
			Guardado.volumen_efectos = v
			Audio.volumen_efectos = v
			# Suena uno para escuchar el volumen elegido al momento.
			Audio.sonar("xp")
			Guardado.guardar()))

	var pantalla := Estilo.boton(_texto_pantalla())
	pantalla.pressed.connect(func() -> void:
		Guardado.pantalla_completa = not Guardado.pantalla_completa
		Guardado.aplicar_ajustes()
		Guardado.guardar()
		pantalla.text = _texto_pantalla())
	columna.add_child(pantalla)

	columna.add_child(Estilo.label(
		"Se puede jugar con teclado (WASD o flechas) o con control", 15,
		Color(0.76, 0.72, 0.70)))

	var espacio := Control.new()
	espacio.custom_minimum_size = Vector2(0, 16)
	columna.add_child(espacio)

	_boton_borrar = Estilo.boton("Borrar todo el progreso")
	_boton_borrar.pressed.connect(_on_borrar)
	columna.add_child(_boton_borrar)

	var volver := Estilo.boton("Volver  (ESC)")
	volver.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/menu.tscn"))
	columna.add_child(volver)


func _texto_pantalla() -> String:
	return "Pantalla completa: %s" % ("si" if Guardado.pantalla_completa else "no")


func _deslizador(titulo: String, valor: float, al_cambiar: Callable) -> VBoxContainer:
	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 2)

	var etiqueta := Estilo.label("%s: %d%%" % [titulo, int(valor * 100.0)], 19)
	caja.add_child(etiqueta)

	var barra := HSlider.new()
	barra.custom_minimum_size = Vector2(300, 26)
	barra.min_value = 0.0
	barra.max_value = 1.0
	barra.step = 0.05
	barra.value = valor
	barra.value_changed.connect(func(v: float) -> void:
		etiqueta.text = "%s: %d%%" % [titulo, int(v * 100.0)]
		al_cambiar.call(v))
	caja.add_child(barra)
	return caja


func _on_borrar() -> void:
	# Dos clics: borrar el progreso sin confirmar seria muy facil de hacer sin
	# querer, y no hay vuelta atras.
	if not _confirmando:
		_confirmando = true
		_boton_borrar.text = "¿Seguro? Se pierde todo. Pulsa otra vez"
		return
	Guardado.borrar_todo()
	Audio.sonar("dano")
	_confirmando = false
	_boton_borrar.text = "Progreso borrado"
	_boton_borrar.disabled = true
