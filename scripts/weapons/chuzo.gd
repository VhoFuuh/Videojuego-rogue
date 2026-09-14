extends Arma

# Chuzo minero: golpe de arco hacia donde miras. Pega fuerte pero de cerca,
# asi que premia meterse al monton en vez de arrancar.
# Evolucion (Chuzo del minero): el arco se cierra en 360 grados.

var _espera := 0.0
var _animacion := 0.0
var _angulo_golpe := 0.0


func _process(delta: float) -> void:
	if _jugador == null:
		return

	_espera -= delta * _jugador.mult_vel_ataque
	if _espera <= 0.0:
		_espera = intervalo()
		_golpear()

	if _animacion > 0.0:
		_animacion -= delta * 4.5
		queue_redraw()


func intervalo() -> float:
	return maxf(0.45, 1.3 - nivel * 0.09)


func dano() -> int:
	return (22 + nivel * 12) * (2 if evolucionada else 1)


func alcance() -> float:
	return 120.0 + nivel * 8.0


func abertura() -> float:
	return TAU if evolucionada else deg_to_rad(135.0)


func _golpear() -> void:
	# Apunta al enemigo mas cercano, no hacia donde caminas. Apuntando al
	# movimiento le pegaba al aire cada vez que el jugador retrocedia, que es
	# justo lo que uno hace todo el rato en este tipo de juego.
	var objetivo := enemigo_mas_cercano(alcance() + 40.0)
	if objetivo != null:
		_angulo_golpe = (objetivo.global_position - _jugador.global_position).angle()
	else:
		_angulo_golpe = _jugador.mirando().angle()
	_animacion = 1.0

	var d := golpe(dano())
	var r := alcance()
	var media := abertura() * 0.5
	for enemigo in enemigos():
		var hacia: Vector2 = enemigo.global_position - _jugador.global_position
		if hacia.length() > r:
			continue
		if evolucionada or absf(hacia.angle_to(Vector2.RIGHT.rotated(_angulo_golpe))) <= media:
			enemigo.recibir_dano(d)
	queue_redraw()


func _draw() -> void:
	if _animacion <= 0.0:
		return
	var media := abertura() * 0.5
	var c := Color(0.85, 0.82, 0.78, _animacion * 0.5)
	if evolucionada:
		c = Color(0.98, 0.72, 0.30, _animacion * 0.5)
	draw_arc(Vector2.ZERO, alcance() * (0.6 + 0.4 * (1.0 - _animacion)),
		_angulo_golpe - media, _angulo_golpe + media, 28, c, 7.0)
