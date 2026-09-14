extends Node

# Archivo temporal de prueba: juega solo para detectar errores.

var juego: Node
var t := 0.0
var proximo_log := 0.0
var mejoras := 0

const CARPETA := "user://capturas"
var momentos := [4.0, 70.0, 121.5, 240.0]
var capturadas := 0
var menu_capturado := false
var cerrando := false
var jefe_capturado := false


func _capturar(nombre: String) -> void:
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(CARPETA)
	var imagen := get_viewport().get_texture().get_image()
	imagen.save_png("%s/%s.png" % [CARPETA, nombre])
	print("captura: %s" % ProjectSettings.globalize_path("%s/%s.png" % [CARPETA, nombre]))


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	juego = load("res://scenes/main.tscn").instantiate()
	add_child(juego)


func _process(delta: float) -> void:
	t += delta

	if juego._menu.visible:
		if not menu_capturado:
			menu_capturado = true
			_capturar("menu_mejoras")
			return
		for boton in juego._menu._fila.get_children():
			if not boton.is_queued_for_deletion():
				boton.pressed.emit()
				mejoras += 1
				break
		return

	if juego._terminado:
		if cerrando:
			return
		cerrando = true
		print("MURIO en %.1fs | mejoras=%d" % [juego.tiempo, mejoras])
		await _capturar("derrota")
		get_tree().quit()
		return

	_mover(t)

	if capturadas < momentos.size() and juego.tiempo >= momentos[capturadas]:
		capturadas += 1
		_capturar("juego_%d" % capturadas)

	if not jefe_capturado and not get_tree().get_nodes_in_group("jefes").is_empty():
		jefe_capturado = true
		_capturar("jefe")

	if juego.tiempo >= proximo_log:
		proximo_log += 30.0
		var detalle := []
		for id in juego._jugador.armas:
			var a = juego._jugador.armas[id]
			detalle.append("%s%d%s" % [id.substr(0, 5), a.nivel, "*" if a.evolucionada else ""])
		print("t=%3.0fs bioma=%d enemigos=%3d jefes=%d lucas=%4d vida=%3d nivel=%2d armas=%s pasivas=%s" % [
			juego.tiempo, juego.indice_bioma,
			get_tree().get_nodes_in_group("enemigos").size(),
			get_tree().get_nodes_in_group("jefes").size(),
			juego.lucas, juego._jugador.vida, juego._jugador.nivel,
			str(detalle), str(juego._jugador.pasivas)])

	if juego.tiempo > 400.0:
		print("SOBREVIVIO el limite de la prueba | mejoras=%d" % mejoras)
		get_tree().quit()


func _mover(tiempo: float) -> void:
	for accion in ["move_left", "move_right", "move_up", "move_down"]:
		Input.action_release(accion)

	# Ronda el borde de la horda en vez de arrancar lejos: un jugador real se
	# mantiene cerca para que las armas cortas alcancen. Con el radio grande de
	# antes, un personaje cuerpo a cuerpo no golpeaba nunca y moria en 10 s.
	const RADIO_HUIDA := 130.0
	var pos: Vector2 = juego._jugador.global_position
	var huida := Vector2.ZERO
	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		var delta: Vector2 = pos - enemigo.global_position
		var d := delta.length()
		if d < RADIO_HUIDA and d > 0.1:
			huida += delta.normalized() * (RADIO_HUIDA - d) / RADIO_HUIDA

	if huida.length() < 0.1:
		huida = Vector2(cos(tiempo * 0.7), sin(tiempo * 0.7))
	huida = huida.normalized()

	if huida.x > 0.35:
		Input.action_press("move_right")
	elif huida.x < -0.35:
		Input.action_press("move_left")
	if huida.y > 0.35:
		Input.action_press("move_down")
	elif huida.y < -0.35:
		Input.action_press("move_up")
