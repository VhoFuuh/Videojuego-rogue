extends Arma

# Cacerolazo: cada cierto tiempo golpea a todos los enemigos alrededor.
# Evolucion (Cacerolazo nacional): radio enorme y empuja a los enemigos.

var _espera := 0.0
var _animacion := 0.0


func iniciar() -> void:
	z_index = -1


func _process(delta: float) -> void:
	if _jugador == null:
		return

	_espera -= delta * _jugador.mult_vel_ataque
	if _espera <= 0.0:
		_espera = intervalo()
		_golpear()

	if _animacion > 0.0:
		_animacion -= delta * 3.0
		queue_redraw()


func radio() -> float:
	return (90.0 + nivel * 20.0) * (1.8 if evolucionada else 1.0)


func dano() -> int:
	return (8 + nivel * 5) * (2 if evolucionada else 1)


func intervalo() -> float:
	return 1.1 if not evolucionada else 0.9


func _golpear() -> void:
	_animacion = 1.0
	var d := golpe(dano())
	var r := radio()
	for enemigo in enemigos():
		var hacia: Vector2 = enemigo.global_position - _jugador.global_position
		if hacia.length() <= r:
			enemigo.recibir_dano(d)
			if evolucionada and is_instance_valid(enemigo) and not enemigo.es_jefe:
				# El empujon da aire cuando te tienen rodeado.
				enemigo.global_position += hacia.normalized() * 90.0
	queue_redraw()


func _draw() -> void:
	if _animacion <= 0.0:
		return
	var t := 1.0 - _animacion
	var c := Color(0.85, 0.85, 0.90, _animacion * 0.7)
	if evolucionada:
		c = Color(0.98, 0.80, 0.35, _animacion * 0.8)
	draw_arc(Vector2.ZERO, radio() * t, 0.0, TAU, 48, c, 3.0 if not evolucionada else 5.0)
