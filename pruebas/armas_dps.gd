extends Node

# Mide cuantos enemigos mata cada arma por si sola, en igualdad de condiciones.
# Sirve para saber cuales sirven como arma inicial: un arma que mata poco al
# principio condena al personaje que empieza con ella.

const SEGUNDOS := 20.0
const OBJETIVO_ENEMIGOS := 40
const RADIO_APARICION := 260.0

var _muertes := 0


func _ready() -> void:
	await get_tree().process_frame
	print("--- muertes en %d s con un arma sola (nivel 1) ---" % SEGUNDOS)
	var resultados := []
	for id in Data.ARMAS:
		var n := await _medir(id)
		resultados.append([id, n])
	resultados.sort_custom(func(a, b): return a[1] > b[1])
	print("\n--- ranking ---")
	for r in resultados:
		print("  %-14s %4d muertes  (%.1f por segundo)" % [r[0], r[1], r[1] / SEGUNDOS])
	get_tree().quit()


func _medir(arma: String) -> int:
	_muertes = 0

	var jugador: Player = preload("res://scripts/player.gd").new()
	add_child(jugador)
	await get_tree().process_frame

	# Se le quita el arma inicial del personaje para dejar solo la que se mide.
	for hijo in jugador.armas.values():
		hijo.queue_free()
	jugador.armas.clear()
	await get_tree().process_frame

	jugador.vida_maxima = 999999
	jugador.vida = 999999
	jugador.agregar_arma(arma)
	await get_tree().process_frame

	var transcurrido := 0.0
	while transcurrido < SEGUNDOS:
		_rellenar(jugador)
		await get_tree().process_frame
		transcurrido += get_process_delta_time()

	for e in get_tree().get_nodes_in_group("enemigos"):
		e.free()
	jugador.free()
	await get_tree().process_frame

	print("  %-14s %4d" % [arma, _muertes])
	return _muertes


func _rellenar(jugador: Player) -> void:
	# Se mantiene una masa constante de enemigos alrededor para que todas las
	# armas midan contra la misma presion.
	var vivos := get_tree().get_nodes_in_group("enemigos").size()
	for i in maxi(0, OBJETIVO_ENEMIGOS - vivos):
		var e := Enemigo.new()
		e.configurar("quiltro", 1.0, 0.0, 1.0)
		var a := randf() * TAU
		e.global_position = jugador.global_position + Vector2(cos(a), sin(a)) \
			* randf_range(RADIO_APARICION * 0.35, RADIO_APARICION)
		e.murio.connect(func(_p, _x, _l): _muertes += 1)
		add_child(e)
