extends Node

# Revisa los menus: captura pantallas y prueba el guardado de punta a punta.

const CARPETA := "user://capturas"


func _ready() -> void:
	await get_tree().process_frame
	_probar_guardado()

	Guardado.lucas = 900
	Guardado.guardar()

	await _ver("res://scenes/menu.tscn", "menu_principal")
	await _ver("res://scenes/fonda.tscn", "fonda")
	get_tree().quit()


func _probar_guardado() -> void:
	print("--- guardado ---")
	Guardado.borrar_todo()

	var mejora: Dictionary = Data.PERMANENTES[0]
	Guardado.lucas = 100
	print("  con $100, cuesta $%d -> puede comprar: %s (esperado false)"
		% [Guardado.costo_de(mejora), Guardado.puede_comprar(mejora)])

	Guardado.lucas = 500
	var antes := Guardado.lucas
	var ok := Guardado.comprar(mejora)
	print("  compra: %s | nivel=%d | lucas %d -> %d"
		% [ok, Guardado.nivel_de(mejora.id), antes, Guardado.lucas])

	var costo_2 := Guardado.costo_de(mejora)
	print("  el segundo nivel cuesta $%d (debe ser mas caro)" % costo_2)

	# Se sube al maximo y se comprueba que ahi se corta.
	Guardado.lucas = 99999
	while not Guardado.al_maximo(mejora):
		Guardado.comprar(mejora)
	print("  al maximo: nivel=%d/%d | comprar de nuevo: %s (esperado false)"
		% [Guardado.nivel_de(mejora.id), mejora.max, Guardado.comprar(mejora)])

	Guardado.registrar_partida(250, 173.5, 14, 2)

	# Round-trip: se recarga desde disco y debe salir lo mismo.
	var lucas_esperadas := Guardado.lucas
	var nivel_esperado := Guardado.nivel_de(mejora.id)
	Guardado.lucas = -1
	Guardado.permanentes = {}
	Guardado.cargar()
	print("  recarga desde disco: lucas=%d (esperado %d) nivel=%d (esperado %d)"
		% [Guardado.lucas, lucas_esperadas, Guardado.nivel_de(mejora.id), nivel_esperado])
	print("  mejor marca guardada: %.1fs nivel %d, %d jefes"
		% [Guardado.mejor_tiempo, Guardado.mejor_nivel, Guardado.jefes_derrotados])

	# Un archivo corrupto no debe romper el juego.
	var f := FileAccess.open(Guardado.RUTA, FileAccess.WRITE)
	f.store_string("{ esto no es json valido ][")
	f.close()
	Guardado.cargar()
	print("  guardado corrupto -> no revienta, lucas=%d" % Guardado.lucas)
	Guardado.borrar_todo()


func _ver(escena: String, nombre: String) -> void:
	# Se instancia como hijo en vez de cambiar de escena: change_scene_to_file
	# liberaria este mismo nodo y el await nunca volveria.
	var nodo: Node = load(escena).instantiate()
	add_child(nodo)
	for i in 6:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(CARPETA)
	get_viewport().get_texture().get_image().save_png("%s/%s.png" % [CARPETA, nombre])
	print("captura: %s" % nombre)
	nodo.queue_free()
	await get_tree().process_frame
