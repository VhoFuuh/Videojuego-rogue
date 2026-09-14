extends Node2D

# Volantines que giran alrededor del jugador y cortan con el hilo curado.

const RADIO_CORTE := 20.0
const INTERVALO_CORTE := 0.25

var nivel := 1

var _angulo := 0.0
var _espera_corte := 0.0
var _jugador: Player


func _ready() -> void:
	_jugador = get_parent() as Player


func _process(delta: float) -> void:
	if _jugador == null:
		return

	_angulo += delta * 2.4 * _jugador.mult_vel_ataque
	queue_redraw()

	_espera_corte -= delta
	if _espera_corte <= 0.0:
		_espera_corte = INTERVALO_CORTE
		_cortar()


func cantidad() -> int:
	return min(2 + nivel, 8)


func distancia() -> float:
	return 70.0 + nivel * 6.0


func dano() -> int:
	return 5 + nivel * 3


func _posiciones() -> Array[Vector2]:
	var puntos: Array[Vector2] = []
	var total := cantidad()
	for i in total:
		var a := _angulo + TAU * float(i) / float(total)
		puntos.append(Vector2(cos(a), sin(a)) * distancia())
	return puntos


func _cortar() -> void:
	var golpe := int(dano() * _jugador.mult_dano)
	var puntos := _posiciones()
	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		var local: Vector2 = enemigo.global_position - _jugador.global_position
		for p in puntos:
			if local.distance_to(p) <= RADIO_CORTE:
				enemigo.recibir_dano(golpe)
				break


func _draw() -> void:
	var c := Color(0.95, 0.55, 0.75)
	for p in _posiciones():
		draw_line(Vector2.ZERO, p, Color(0.9, 0.9, 0.9, 0.25), 1.0)
		# Rombo simple: el volantin.
		var puntos := PackedVector2Array([
			p + Vector2(0, -9), p + Vector2(8, 0), p + Vector2(0, 9), p + Vector2(-8, 0)
		])
		draw_colored_polygon(puntos, c)
