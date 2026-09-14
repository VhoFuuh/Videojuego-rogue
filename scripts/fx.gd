extends Node2D

# Efectos visuales (autoload "Fx"): numeros de daño, particulas y sacudida.
#
# Todo se dibuja desde este unico nodo en vez de crear uno por efecto. Con
# cientos de enemigos golpeados por segundo, un nodo por numero seria carisimo.

const MAX_NUMEROS := 35
const MAX_PARTICULAS := 160
const DURACION_NUMERO := 0.65
const DURACION_PARTICULA := 0.45

var camara: Camera2D

var _numeros: Array[Dictionary] = []
var _particulas: Array[Dictionary] = []
var _sacudida := 0.0
var _fuente: Font


func _ready() -> void:
	z_index = 50
	_fuente = ThemeDB.fallback_font


func limpiar() -> void:
	_numeros.clear()
	_particulas.clear()
	_sacudida = 0.0


func numero(pos: Vector2, cantidad: int, color := Color(1, 1, 1)) -> void:
	# Si ya hay muchos en pantalla no se agregan mas: son adorno, no informacion
	# critica, y mas de treinta a la vez no se leen igual.
	if _numeros.size() >= MAX_NUMEROS:
		return
	_numeros.append({
		"pos": pos + Vector2(randf_range(-6.0, 6.0), -10.0),
		"vel": Vector2(randf_range(-22.0, 22.0), -70.0),
		"texto": str(cantidad),
		"color": color,
		"vida": DURACION_NUMERO,
	})


func explosion(pos: Vector2, color: Color, cantidad := 7) -> void:
	for i in cantidad:
		if _particulas.size() >= MAX_PARTICULAS:
			return
		var angulo := randf() * TAU
		_particulas.append({
			"pos": pos,
			"vel": Vector2(cos(angulo), sin(angulo)) * randf_range(70.0, 210.0),
			"color": color,
			"radio": randf_range(2.0, 4.5),
			"vida": DURACION_PARTICULA,
		})


func sacudir(fuerza: float) -> void:
	_sacudida = maxf(_sacudida, fuerza)


func _process(delta: float) -> void:
	var i := _numeros.size() - 1
	while i >= 0:
		var n := _numeros[i]
		n.vida -= delta
		if n.vida <= 0.0:
			_numeros.remove_at(i)
		else:
			n.pos += n.vel * delta
			n.vel.y += 140.0 * delta
		i -= 1

	i = _particulas.size() - 1
	while i >= 0:
		var p := _particulas[i]
		p.vida -= delta
		if p.vida <= 0.0:
			_particulas.remove_at(i)
		else:
			p.pos += p.vel * delta
			p.vel *= 1.0 - 4.0 * delta
		i -= 1

	if _sacudida > 0.0:
		_sacudida = maxf(0.0, _sacudida - delta * 26.0)
		if is_instance_valid(camara):
			camara.offset = Vector2(
				randf_range(-_sacudida, _sacudida), randf_range(-_sacudida, _sacudida))
	elif is_instance_valid(camara) and camara.offset != Vector2.ZERO:
		camara.offset = Vector2.ZERO

	queue_redraw()


func _draw() -> void:
	for p in _particulas:
		var t: float = p.vida / DURACION_PARTICULA
		var c: Color = p.color
		draw_circle(p.pos, p.radio * t, Color(c.r, c.g, c.b, t))

	for n in _numeros:
		var t: float = n.vida / DURACION_NUMERO
		var c: Color = n.color
		# Sombra para que el numero se lea sobre cualquier fondo.
		draw_string(_fuente, n.pos + Vector2(1, 2), n.texto,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(0, 0, 0, t * 0.7))
		draw_string(_fuente, n.pos, n.texto,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(c.r, c.g, c.b, t))
