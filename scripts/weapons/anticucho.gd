extends Arma

# Arma inicial: dispara sola al enemigo mas cercano.
# Es a distancia a proposito: asi retroceder sigue siendo productivo.
# Evolucion (Parrillada completa): dispara en circulo, sin apuntar.

const ALCANCE := 560.0

var _espera := 0.0


func _process(delta: float) -> void:
	if _jugador == null:
		return
	_espera -= delta * _jugador.mult_vel_ataque
	if _espera <= 0.0:
		_espera = intervalo()
		_disparar()


func intervalo() -> float:
	return maxf(0.18, (0.52 - nivel * 0.04) * (0.7 if evolucionada else 1.0))


func dano() -> int:
	return (9 + nivel * 5) * (2 if evolucionada else 1)


func proyectiles() -> int:
	if evolucionada:
		return 8
	return 1 + int(nivel / 3)


func perforacion() -> int:
	return (4 + nivel) + (3 if evolucionada else 0)


func _disparar() -> void:
	var base: Vector2
	if evolucionada:
		# La parrillada no apunta: cubre las ocho direcciones.
		base = Vector2.RIGHT.rotated(randf() * TAU)
	else:
		var objetivo := enemigo_mas_cercano(ALCANCE)
		if objetivo == null:
			return
		base = (objetivo.global_position - _jugador.global_position).normalized()

	Audio.sonar("disparo", randf_range(0.92, 1.08))

	var total := proyectiles()
	var contenedor := mundo()
	for i in total:
		var desvio: float
		if evolucionada:
			desvio = TAU * float(i) / float(total)
		elif total == 1:
			desvio = 0.0
		else:
			desvio = lerpf(-0.22, 0.22, float(i) / float(total - 1))

		var bala := Proyectil.new()
		bala.direccion = base.rotated(desvio)
		bala.dano = golpe(dano())
		bala.perforacion = perforacion()
		bala.ardiente = evolucionada
		bala.global_position = _jugador.global_position
		contenedor.add_child(bala)
