extends Arma

# Quiltro fiel: un perro que sale solo a morder al enemigo mas cercano y
# vuelve contigo. No lo controlas, y esa es la gracia.
# Evolucion (La jauria): tres perros.

const RADIO_MORDIDA := 26.0
const DISTANCIA_VUELTA := 90.0

var _perros: Array = []


func iniciar() -> void:
	z_index = 1
	_ajustar_perros()


func cantidad() -> int:
	return 3 if evolucionada else 1


func velocidad() -> float:
	return 260.0 + nivel * 18.0


func dano() -> int:
	return (14 + nivel * 8) * (2 if evolucionada else 1)


func evolucionar() -> void:
	super()
	_ajustar_perros()


func _ajustar_perros() -> void:
	while _perros.size() < cantidad():
		_perros.append({
			"pos": _jugador.global_position if _jugador != null else Vector2.ZERO,
			"objetivo": null,
			"espera": randf() * 0.6,
		})


func _process(delta: float) -> void:
	if _jugador == null:
		return
	_ajustar_perros()

	for perro in _perros:
		_mover_perro(perro, delta)
	queue_redraw()


func _mover_perro(perro: Dictionary, delta: float) -> void:
	var objetivo = perro.objetivo
	if objetivo == null or not is_instance_valid(objetivo):
		perro.objetivo = enemigo_mas_cercano(520.0)
		objetivo = perro.objetivo

	var destino: Vector2
	if objetivo != null:
		destino = objetivo.global_position
	else:
		# Sin presa a la vista, trota al lado del jugador.
		destino = _jugador.global_position + Vector2.RIGHT.rotated(
			Time.get_ticks_msec() / 600.0) * DISTANCIA_VUELTA

	var hacia: Vector2 = destino - perro.pos
	var distancia := hacia.length()
	if distancia > 1.0:
		perro.pos += hacia / distancia * velocidad() * delta

	perro.espera -= delta
	if objetivo != null and distancia <= RADIO_MORDIDA and perro.espera <= 0.0:
		perro.espera = 0.45
		objetivo.recibir_dano(golpe(dano()))
		perro.objetivo = null


func _draw() -> void:
	for perro in _perros:
		# Se dibuja en coordenadas locales porque el nodo cuelga del jugador.
		var local: Vector2 = perro.pos - _jugador.global_position
		var lado := 1.0 if local.x >= 0.0 else -1.0
		draw_set_transform(local, 0.0, Vector2(lado, 1.0))
		Dibujos.enemigo(self, "quiltro", 11.0,
			Color(0.92, 0.86, 0.72) if evolucionada else Color(0.75, 0.62, 0.45), 1.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
