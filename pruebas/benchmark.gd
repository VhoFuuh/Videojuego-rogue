extends Node

# Mide cuantos enemigos aguanta el juego a 60 fps.
# Uso: godot --headless res://pruebas/benchmark.tscn

const FRAMES_POR_PRUEBA := 300
const CANTIDADES := [60, 120, 180, 240]

var _jugador: Player
var _resultados: Array[String] = []


func _ready() -> void:
	_jugador = preload("res://scripts/player.gd").new()
	add_child(_jugador)
	await get_tree().process_frame

	for cantidad in CANTIDADES:
		await _medir(cantidad)

	print("\n=== RESULTADO ===")
	for linea in _resultados:
		print(linea)
	get_tree().quit()


func _medir(cantidad: int) -> void:
	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		enemigo.free()

	for i in cantidad:
		var enemigo := Enemigo.new()
		enemigo.configurar("quiltro", 20.0, 0.0, 1.0)
		var angulo := randf() * TAU
		enemigo.global_position = Vector2(cos(angulo), sin(angulo)) * randf_range(60.0, 420.0)
		add_child(enemigo)

	# Se descartan unos frames para que el motor se estabilice.
	for i in 30:
		await get_tree().physics_frame

	# Se miden los medidores internos del motor: el reloj no sirve porque el
	# bucle esta fijado a 60 Hz y siempre daria 16.6 ms.
	var suma_proceso := 0.0
	var suma_fisica := 0.0
	for i in FRAMES_POR_PRUEBA:
		await get_tree().physics_frame
		suma_proceso += Performance.get_monitor(Performance.TIME_PROCESS)
		suma_fisica += Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)

	var proceso_ms := suma_proceso / FRAMES_POR_PRUEBA * 1000.0
	var fisica_ms := suma_fisica / FRAMES_POR_PRUEBA * 1000.0
	var total_ms := proceso_ms + fisica_ms
	var margen := 16.6 / maxf(total_ms, 0.001)
	_resultados.append(
		"%3d enemigos -> proceso %5.2f ms + fisica %5.2f ms = %5.2f ms (%.1fx de margen a 60 fps)"
		% [cantidad, proceso_ms, fisica_ms, total_ms, margen])
	print(_resultados[-1])
