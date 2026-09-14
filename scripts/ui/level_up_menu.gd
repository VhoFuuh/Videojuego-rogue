class_name MenuMejoras
extends CanvasLayer

signal elegida(mejora: Dictionary)

var _fila: HBoxContainer
var _raiz: Control


func _ready() -> void:
	layer = 20
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	visible = false

	_raiz = Control.new()
	_raiz.set_anchors_preset(Control.PRESET_FULL_RECT)
	_raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_raiz)

	var fondo := ColorRect.new()
	fondo.color = Color(0, 0, 0, 0.72)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_raiz.add_child(fondo)

	var columna := VBoxContainer.new()
	columna.set_anchors_preset(Control.PRESET_CENTER)
	columna.grow_horizontal = Control.GROW_DIRECTION_BOTH
	columna.grow_vertical = Control.GROW_DIRECTION_BOTH
	columna.add_theme_constant_override("separation", 24)
	columna.alignment = BoxContainer.ALIGNMENT_CENTER
	_raiz.add_child(columna)

	var titulo := Label.new()
	titulo.text = "¡SUBISTE DE NIVEL!"
	titulo.add_theme_font_size_override("font_size", 40)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	columna.add_child(titulo)

	_fila = HBoxContainer.new()
	_fila.add_theme_constant_override("separation", 20)
	_fila.alignment = BoxContainer.ALIGNMENT_CENTER
	columna.add_child(_fila)


func mostrar(opciones: Array) -> void:
	for hijo in _fila.get_children():
		_fila.remove_child(hijo)
		hijo.queue_free()

	for opcion in opciones:
		_fila.add_child(_crear_carta(opcion))

	visible = true
	# El primer boton queda enfocado para poder elegir con el teclado.
	await get_tree().process_frame
	if _fila.get_child_count() > 0:
		_fila.get_child(0).grab_focus()


func ocultar() -> void:
	visible = false


func _crear_carta(mejora: Dictionary) -> Button:
	var boton := Button.new()
	boton.custom_minimum_size = Vector2(250, 170)

	var columna := VBoxContainer.new()
	columna.set_anchors_preset(Control.PRESET_FULL_RECT)
	columna.offset_left = 14
	columna.offset_right = -14
	columna.offset_top = 14
	columna.offset_bottom = -14
	columna.mouse_filter = Control.MOUSE_FILTER_IGNORE
	columna.add_theme_constant_override("separation", 10)
	boton.add_child(columna)

	var icono := ColorRect.new()
	icono.color = mejora.color
	icono.custom_minimum_size = Vector2(0, 40)
	icono.mouse_filter = Control.MOUSE_FILTER_IGNORE
	columna.add_child(icono)

	var nombre := Label.new()
	nombre.text = mejora.nombre
	nombre.add_theme_font_size_override("font_size", 20)
	nombre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nombre.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	nombre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	columna.add_child(nombre)

	var desc := Label.new()
	desc.text = mejora.desc
	desc.add_theme_font_size_override("font_size", 14)
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.modulate = Color(1, 1, 1, 0.75)
	desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	columna.add_child(desc)

	boton.pressed.connect(func() -> void: elegida.emit(mejora))
	return boton
