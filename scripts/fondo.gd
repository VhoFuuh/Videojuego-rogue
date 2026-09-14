class_name Fondo
extends Node2D

# Suelo y decorado del bioma.
#
# Los adornos no son nodos: se calculan a partir de la celda del mapa, asi que
# el mundo es infinito y no hay nada que crear ni borrar. Solo se redibuja
# cuando el jugador cambia de celda, no en cada frame.

const CELDA_SUELO := 64.0
const CELDA_ADORNO := 230.0
const EXTENSION := Vector2(950, 680)

var bioma := 0

var _ultimo_centro := Vector2(99999, 99999)
var _jugador: Node2D


func _ready() -> void:
	z_index = -10


func seguir(jugador: Node2D) -> void:
	_jugador = jugador


func cambiar_bioma(indice: int) -> void:
	bioma = indice
	_ultimo_centro = Vector2(99999, 99999)
	queue_redraw()


func _process(_delta: float) -> void:
	if not is_instance_valid(_jugador):
		return
	# Solo se rehace el dibujo al cruzar de celda. Redibujar el decorado en cada
	# frame costaria caro y no se notaria ninguna diferencia.
	var centro: Vector2 = (_jugador.global_position / CELDA_SUELO).floor()
	if centro != _ultimo_centro:
		_ultimo_centro = centro
		queue_redraw()


# Ruido entero estable: la misma celda da siempre el mismo adorno.
static func _ruido(x: int, y: int, sal: int) -> int:
	var h := x * 374761393 + y * 668265263 + sal * 1442695040
	h = (h ^ (h >> 13)) * 1274126177
	return absi(h ^ (h >> 16))


func _draw() -> void:
	if not is_instance_valid(_jugador):
		return
	var b: Dictionary = Data.BIOMAS[bioma]
	var centro: Vector2 = _jugador.global_position
	var inicio := ((centro - EXTENSION) / CELDA_SUELO).floor() * CELDA_SUELO
	var fin := centro + EXTENSION
	var color: Color = b.suelo

	var x := inicio.x
	while x < fin.x:
		draw_line(Vector2(x, inicio.y), Vector2(x, fin.y), color, 1.0)
		x += CELDA_SUELO
	var y := inicio.y
	while y < fin.y:
		draw_line(Vector2(inicio.x, y), Vector2(fin.x, y), color, 1.0)
		y += CELDA_SUELO

	_dibujar_adornos(centro, color)


func _dibujar_adornos(centro: Vector2, color: Color) -> void:
	var desde := ((centro - EXTENSION) / CELDA_ADORNO).floor()
	var hasta := ((centro + EXTENSION) / CELDA_ADORNO).ceil()

	for cy in range(int(desde.y), int(hasta.y) + 1):
		for cx in range(int(desde.x), int(hasta.x) + 1):
			var r := _ruido(cx, cy, bioma)
			# Aproximadamente uno de cada tres cuadrantes lleva adorno.
			if r % 3 != 0:
				continue
			var pos := Vector2(
				cx * CELDA_ADORNO + float(r % 140),
				cy * CELDA_ADORNO + float((r / 140) % 140))
			var escala := 0.75 + float(r % 50) / 100.0
			draw_set_transform(pos, 0.0, Vector2(escala, escala))
			_adorno(bioma, color, r)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _adorno(indice: int, suelo: Color, r: int) -> void:
	var sombra := Color(0, 0, 0, 0.18)
	match indice:
		0: _ramada(suelo, sombra, r)
		1: _cactus(suelo, sombra)
		2: _casa_cerro(suelo, sombra, r)
		3: _palafito(suelo, sombra)
		_: _moai_piedra(suelo, sombra)


func _ramada(suelo: Color, sombra: Color, r: int) -> void:
	draw_colored_polygon(Dibujos.elipse(Vector2(0, 26), 46, 11), sombra)
	# Techo de ramas.
	draw_colored_polygon(PackedVector2Array([
		Vector2(-54, -12), Vector2(54, -12), Vector2(44, 2), Vector2(-44, 2)]),
		suelo.lightened(0.28))
	for i in 4:
		var x := -40.0 + i * 26.0
		draw_line(Vector2(x, 2), Vector2(x, 24), suelo.darkened(0.25), 4.0)
	# Banderitas colgando.
	var colores := [Color(0.80, 0.22, 0.22), Color(0.92, 0.90, 0.86), Color(0.22, 0.34, 0.72)]
	for i in 5:
		var x := -44.0 + i * 22.0
		draw_colored_polygon(PackedVector2Array([
			Vector2(x - 6, -12), Vector2(x + 6, -12), Vector2(x, -2)]),
			colores[(r + i) % 3])


func _cactus(suelo: Color, sombra: Color) -> void:
	draw_colored_polygon(Dibujos.elipse(Vector2(0, 28), 20, 7), sombra)
	var verde := Color(0.32, 0.46, 0.26)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-8, 28), Vector2(8, 28), Vector2(8, -34), Vector2(-8, -34)]), verde)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-26, -4), Vector2(-8, -4), Vector2(-8, 10), Vector2(-26, 10)]), verde)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-26, -22), Vector2(-16, -22), Vector2(-16, 0), Vector2(-26, 0)]), verde)
	draw_colored_polygon(PackedVector2Array([
		Vector2(8, -18), Vector2(24, -18), Vector2(24, -2), Vector2(8, -2)]), verde)


func _casa_cerro(suelo: Color, sombra: Color, r: int) -> void:
	draw_colored_polygon(Dibujos.elipse(Vector2(0, 26), 34, 8), sombra)
	# Las casas de Valparaiso son de colores fuertes.
	var paleta := [Color(0.82, 0.38, 0.30), Color(0.35, 0.58, 0.68),
		Color(0.85, 0.70, 0.30), Color(0.45, 0.62, 0.42)]
	var c: Color = paleta[r % 4]
	draw_colored_polygon(PackedVector2Array([
		Vector2(-30, 24), Vector2(30, 24), Vector2(30, -14), Vector2(-30, -14)]), c)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-34, -14), Vector2(34, -14), Vector2(0, -38)]), c.darkened(0.30))
	draw_rect(Rect2(-18, -6, 14, 14), Color(0.22, 0.26, 0.30))
	draw_rect(Rect2(6, -6, 14, 14), Color(0.22, 0.26, 0.30))


func _palafito(suelo: Color, sombra: Color) -> void:
	draw_colored_polygon(Dibujos.elipse(Vector2(0, 34), 36, 8), sombra)
	# Pilotes sobre el agua.
	for i in 4:
		var x := -24.0 + i * 16.0
		draw_line(Vector2(x, 12), Vector2(x, 34), Color(0.30, 0.24, 0.20), 4.0)
	var madera := Color(0.42, 0.34, 0.28)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-30, 12), Vector2(30, 12), Vector2(30, -14), Vector2(-30, -14)]), madera)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-34, -14), Vector2(34, -14), Vector2(0, -36)]), madera.darkened(0.28))
	draw_rect(Rect2(-8, -6, 16, 16), Color(0.78, 0.68, 0.32))


func _moai_piedra(suelo: Color, sombra: Color) -> void:
	draw_colored_polygon(Dibujos.elipse(Vector2(0, 32), 26, 8), sombra)
	# Moai chico de fondo: puro decorado, no es el enemigo.
	var piedra := Color(0.42, 0.42, 0.40)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-18, 32), Vector2(18, 32), Vector2(20, -18),
		Vector2(14, -34), Vector2(-14, -34), Vector2(-20, -18)]), piedra)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-17, -18), Vector2(17, -18), Vector2(15, -8), Vector2(-15, -8)]),
		piedra.darkened(0.30))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-4, -8), Vector2(4, -8), Vector2(6, 8), Vector2(-6, 8)]),
		piedra.darkened(0.15))
