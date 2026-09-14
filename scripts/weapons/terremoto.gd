extends Arma

# Copa de terremoto: la tira al suelo y deja un charco que daña con el tiempo.
# Sirve para cortar el paso, no para matar rapido.
# Evolucion (Maremoto): charcos enormes y mas duraderos.

const ALCANCE := 420.0

var _espera := 0.0


func _process(delta: float) -> void:
	if _jugador == null:
		return
	_espera -= delta * _jugador.mult_vel_ataque
	if _espera <= 0.0:
		_espera = intervalo()
		_lanzar()


func intervalo() -> float:
	return maxf(1.0, 2.6 - nivel * 0.18)


func dano() -> int:
	return (5 + nivel * 3) * (2 if evolucionada else 1)


func radio() -> float:
	return (55.0 + nivel * 7.0) * (1.9 if evolucionada else 1.0)


func duracion() -> float:
	return (3.0 + nivel * 0.35) * (1.8 if evolucionada else 1.0)


func cantidad() -> int:
	if evolucionada:
		return 3
	return 1 + int(nivel / 5)


func _lanzar() -> void:
	var objetivo := enemigo_mas_cercano(ALCANCE)
	var centro: Vector2 = objetivo.global_position if objetivo != null \
		else _jugador.global_position + _jugador.mirando() * 180.0

	for i in cantidad():
		var charco := Charco.new()
		charco.radio = radio()
		charco.dano = golpe(dano())
		charco.duracion = duracion()
		if evolucionada:
			charco.color = Color(0.55, 0.80, 0.95)
		# Se dispersan un poco para cubrir mas terreno.
		var dispersion := Vector2.ZERO if i == 0 else \
			Vector2.RIGHT.rotated(randf() * TAU) * randf_range(50.0, 130.0)
		charco.global_position = centro + dispersion
		mundo().add_child(charco)
