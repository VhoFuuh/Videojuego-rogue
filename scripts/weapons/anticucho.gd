extends Node2D

# Arma inicial: dispara sola al enemigo mas cercano.
# Es a distancia a proposito: asi retroceder sigue siendo productivo.

const ALCANCE := 560.0

var nivel := 1

var _espera := 0.0
var _jugador: Player


func _ready() -> void:
	_jugador = get_parent() as Player


func _process(delta: float) -> void:
	if _jugador == null:
		return
	_espera -= delta * _jugador.mult_vel_ataque
	if _espera <= 0.0:
		_espera = intervalo()
		_disparar()


func intervalo() -> float:
	return maxf(0.30, 0.80 - nivel * 0.05)


func dano() -> int:
	return 9 + nivel * 5


func proyectiles() -> int:
	return 1 + int(nivel / 3)


func perforacion() -> int:
	return 1 + int(nivel / 4)


func _enemigo_mas_cercano() -> Node2D:
	var mejor: Node2D = null
	var mejor_distancia := ALCANCE
	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		var d: float = _jugador.global_position.distance_to(enemigo.global_position)
		if d < mejor_distancia:
			mejor_distancia = d
			mejor = enemigo
	return mejor


func _disparar() -> void:
	var objetivo := _enemigo_mas_cercano()
	if objetivo == null:
		return

	var base := (objetivo.global_position - _jugador.global_position).normalized()
	var total := proyectiles()
	var contenedor := _jugador.get_parent()

	for i in total:
		# Con varios proyectiles se abren en abanico.
		var desvio := 0.0 if total == 1 else lerpf(-0.22, 0.22, float(i) / float(total - 1))
		var bala := Proyectil.new()
		bala.direccion = base.rotated(desvio)
		bala.dano = int(dano() * _jugador.mult_dano)
		bala.perforacion = perforacion()
		bala.global_position = _jugador.global_position
		contenedor.add_child(bala)
