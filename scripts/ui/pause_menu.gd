class_name MenuPausa
extends CanvasLayer

signal continuar
signal salir


func _ready() -> void:
	layer = 25
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	visible = false

	var raiz := Control.new()
	raiz.set_anchors_preset(Control.PRESET_FULL_RECT)
	raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(raiz)
	raiz.add_child(Estilo.fondo_oscuro())

	var columna := Estilo.columna_centrada(18)
	raiz.add_child(columna)
	columna.add_child(Estilo.label("PAUSA", 46))

	var seguir := Estilo.boton("Seguir jugando")
	seguir.pressed.connect(func() -> void: continuar.emit())
	columna.add_child(seguir)

	var volver := Estilo.boton("Volver a la fonda")
	volver.pressed.connect(func() -> void: salir.emit())
	columna.add_child(volver)


func _unhandled_input(evento: InputEvent) -> void:
	# El juego esta pausado, asi que game.gd no corre: el ESC para reanudar
	# tiene que atenderlo este menu, que si procesa en pausa.
	if visible and evento.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		continuar.emit()


func mostrar() -> void:
	visible = true
	await get_tree().process_frame
	# El foco parte en el primer boton para poder navegar con el teclado.
	var columna := get_child(0).get_child(1)
	if columna.get_child_count() > 1:
		columna.get_child(1).grab_focus()


func ocultar() -> void:
	visible = false
