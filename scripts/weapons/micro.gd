extends Arma

# Micro amarilla: cada cierto rato pasa una micro atropellando en linea recta.
# Hace mucho daño pero no la controlas: hay que aprovechar cuando pasa.
# Evolucion (Transantiago): pasan varias y por los dos lados.

const DISTANCIA_SALIDA := 620.0

var _espera := 0.4


func _process(delta: float) -> void:
	if _jugador == null:
		return
	_espera -= delta * _jugador.mult_vel_ataque
	if _espera <= 0.0:
		_espera = intervalo()
		_pasar()


func intervalo() -> float:
	return maxf(0.85, 1.9 - nivel * 0.22)


func dano() -> int:
	return (16 + nivel * 11) * (2 if evolucionada else 1)


func cantidad() -> int:
	if evolucionada:
		return 3
	return 1 + int(nivel / 4)


func _pasar() -> void:
	Audio.sonar("jefe", 1.6, 0.35)
	var contenedor := mundo()

	for i in cantidad():
		# Apunta al jugador pero sale desde lejos, asi cruza toda la pantalla.
		var angulo := randf() * TAU
		var direccion := Vector2(cos(angulo), sin(angulo))
		var desfase := 0.0 if i == 0 else randf_range(-120.0, 120.0)

		var micro := MicroBus.new()
		micro.direccion = direccion
		micro.dano = golpe(dano())
		if evolucionada:
			micro.color = Color(0.35, 0.66, 0.92)
			micro.velocidad = 760.0
		micro.global_position = _jugador.global_position \
			- direccion * DISTANCIA_SALIDA \
			+ direccion.orthogonal() * desfase
		contenedor.add_child(micro)
