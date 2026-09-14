extends Arma

# Volantines que giran alrededor del jugador y cortan con el hilo curado.
# Evolucion (Comision de volantines): mas volantines, mas lejos y mas rapidos.

const RADIO_CORTE := 20.0
const INTERVALO_CORTE := 0.25

var _angulo := 0.0
var _espera_corte := 0.0


func _process(delta: float) -> void:
	if _jugador == null:
		return

	var giro := 2.4 * (1.7 if evolucionada else 1.0)
	_angulo += delta * giro * _jugador.mult_vel_ataque
	queue_redraw()

	_espera_corte -= delta
	if _espera_corte <= 0.0:
		_espera_corte = INTERVALO_CORTE
		_cortar()


func cantidad() -> int:
	if evolucionada:
		return 10
	return mini(2 + nivel, 8)


func distancia() -> float:
	return (70.0 + nivel * 6.0) * (1.5 if evolucionada else 1.0)


func dano() -> int:
	return (5 + nivel * 3) * (2 if evolucionada else 1)


func _posiciones() -> Array[Vector2]:
	var puntos: Array[Vector2] = []
	var total := cantidad()
	for i in total:
		var a := _angulo + TAU * float(i) / float(total)
		puntos.append(Vector2(cos(a), sin(a)) * distancia())
	return puntos


func _cortar() -> void:
	var d := golpe(dano())
	var puntos := _posiciones()
	for enemigo in enemigos():
		var local: Vector2 = enemigo.global_position - _jugador.global_position
		for p in puntos:
			if local.distance_to(p) <= RADIO_CORTE:
				enemigo.recibir_dano(d)
				break


func _draw() -> void:
	var c := Color(0.95, 0.55, 0.75) if not evolucionada else Color(0.98, 0.78, 0.32)
	for p in _posiciones():
		draw_line(Vector2.ZERO, p, Color(0.9, 0.9, 0.9, 0.25), 1.0)
		draw_colored_polygon(PackedVector2Array([
			p + Vector2(0, -9), p + Vector2(8, 0), p + Vector2(0, 9), p + Vector2(-8, 0)]), c)
