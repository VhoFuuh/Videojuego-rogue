class_name Hud
extends CanvasLayer

var _barra_xp: ProgressBar
var _barra_vida: ProgressBar
var _lbl_vida: Label
var _lbl_tiempo: Label
var _lbl_bioma: Label
var _lbl_nivel: Label
var _lbl_anuncio: Label
var _tiempo_anuncio := 0.0


func _ready() -> void:
	layer = 10

	_barra_xp = _crear_barra(Color(0.40, 0.85, 0.50), Color(0.10, 0.14, 0.12))
	_barra_xp.anchor_right = 1.0
	_barra_xp.offset_left = 0.0
	_barra_xp.offset_right = 0.0
	_barra_xp.offset_top = 0.0
	_barra_xp.offset_bottom = 12.0
	_barra_xp.max_value = 5.0
	add_child(_barra_xp)

	_barra_vida = _crear_barra(Color(0.85, 0.30, 0.35), Color(0.18, 0.10, 0.11))
	_barra_vida.offset_left = 16.0
	_barra_vida.offset_right = 226.0
	_barra_vida.offset_top = 26.0
	_barra_vida.offset_bottom = 48.0
	_barra_vida.max_value = 100.0
	add_child(_barra_vida)

	_lbl_vida = _crear_label(18)
	_lbl_vida.offset_left = 24.0
	_lbl_vida.offset_top = 27.0
	add_child(_lbl_vida)

	_lbl_nivel = _crear_label(18)
	_lbl_nivel.offset_left = 240.0
	_lbl_nivel.offset_top = 27.0
	add_child(_lbl_nivel)

	_lbl_tiempo = _crear_label(34)
	_lbl_tiempo.anchor_left = 0.5
	_lbl_tiempo.anchor_right = 0.5
	_lbl_tiempo.offset_left = -80.0
	_lbl_tiempo.offset_right = 80.0
	_lbl_tiempo.offset_top = 22.0
	_lbl_tiempo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_lbl_tiempo)

	_lbl_bioma = _crear_label(18)
	_lbl_bioma.anchor_left = 0.5
	_lbl_bioma.anchor_right = 0.5
	_lbl_bioma.offset_left = -160.0
	_lbl_bioma.offset_right = 160.0
	_lbl_bioma.offset_top = 62.0
	_lbl_bioma.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_bioma.modulate = Color(1, 1, 1, 0.7)
	add_child(_lbl_bioma)

	_lbl_anuncio = _crear_label(52)
	_lbl_anuncio.anchor_left = 0.5
	_lbl_anuncio.anchor_right = 0.5
	_lbl_anuncio.anchor_top = 0.5
	_lbl_anuncio.anchor_bottom = 0.5
	_lbl_anuncio.offset_left = -400.0
	_lbl_anuncio.offset_right = 400.0
	_lbl_anuncio.offset_top = -185.0
	_lbl_anuncio.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_anuncio.modulate = Color(1, 1, 1, 0)
	add_child(_lbl_anuncio)


func _process(delta: float) -> void:
	if _tiempo_anuncio <= 0.0:
		return
	_tiempo_anuncio -= delta
	# Se mantiene opaco y recien al final se desvanece.
	_lbl_anuncio.modulate = Color(1, 1, 1, clampf(_tiempo_anuncio, 0.0, 1.0))


func anunciar(texto: String) -> void:
	_lbl_anuncio.text = texto
	_tiempo_anuncio = 2.5
	_lbl_anuncio.modulate = Color(1, 1, 1, 1)


func _crear_label(tamano: int) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", tamano)
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	l.add_theme_constant_override("shadow_offset_y", 2)
	return l


func _crear_barra(relleno: Color, fondo: Color) -> ProgressBar:
	var barra := ProgressBar.new()
	barra.show_percentage = false

	var estilo_fondo := StyleBoxFlat.new()
	estilo_fondo.bg_color = fondo
	estilo_fondo.corner_radius_top_left = 3
	estilo_fondo.corner_radius_top_right = 3
	estilo_fondo.corner_radius_bottom_left = 3
	estilo_fondo.corner_radius_bottom_right = 3
	barra.add_theme_stylebox_override("background", estilo_fondo)

	var estilo_relleno := StyleBoxFlat.new()
	estilo_relleno.bg_color = relleno
	estilo_relleno.corner_radius_top_left = 3
	estilo_relleno.corner_radius_top_right = 3
	estilo_relleno.corner_radius_bottom_left = 3
	estilo_relleno.corner_radius_bottom_right = 3
	barra.add_theme_stylebox_override("fill", estilo_relleno)

	return barra


func set_vida(actual: int, maxima: int) -> void:
	_barra_vida.max_value = maxima
	_barra_vida.value = actual
	_lbl_vida.text = "%d / %d" % [actual, maxima]


func set_xp(actual: int, necesaria: int, nivel: int) -> void:
	_barra_xp.max_value = necesaria
	_barra_xp.value = actual
	_lbl_nivel.text = "Nivel %d" % nivel


func set_tiempo(segundos: float) -> void:
	_lbl_tiempo.text = "%d:%02d" % [int(segundos) / 60, int(segundos) % 60]


func set_bioma(nombre: String) -> void:
	_lbl_bioma.text = nombre
