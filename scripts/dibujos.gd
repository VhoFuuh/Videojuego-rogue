class_name Dibujos
extends RefCounted

# Siluetas de todos los personajes. Se dibujan con poligonos en vez de imagenes
# para no depender de archivos externos.
#
# Ojo: _draw() solo corre cuando el nodo se crea o se llama queue_redraw(), no
# cada frame, asi que el detalle aca no cuesta rendimiento.

const BORDE := Color(0.08, 0.06, 0.09)


# --- Helpers ----------------------------------------------------------------

static func elipse(centro: Vector2, rx: float, ry: float, lados: int = 16) -> PackedVector2Array:
	var puntos := PackedVector2Array()
	for i in lados:
		var a := TAU * float(i) / float(lados)
		puntos.append(centro + Vector2(cos(a) * rx, sin(a) * ry))
	return puntos


static func figura(c: CanvasItem, puntos: PackedVector2Array, col: Color, grosor := 1.5) -> void:
	c.draw_colored_polygon(puntos, col)
	if grosor > 0.0:
		var cerrado := puntos.duplicate()
		cerrado.append(puntos[0])
		c.draw_polyline(cerrado, BORDE, grosor)


static func mover(puntos: PackedVector2Array, desplazamiento: Vector2) -> PackedVector2Array:
	var salida := PackedVector2Array()
	for p in puntos:
		salida.append(p + desplazamiento)
	return salida


# --- Jugador ----------------------------------------------------------------

static func huaso(c: CanvasItem, r: float, cuerpo: Color, mirando: Vector2) -> void:
	var lado := 1.0 if mirando.x >= 0.0 else -1.0

	# Manta (poncho): trapecio ancho.
	var manta := PackedVector2Array([
		Vector2(-r * 0.95, r * 0.95), Vector2(r * 0.95, r * 0.95),
		Vector2(r * 0.55, -r * 0.15), Vector2(-r * 0.55, -r * 0.15),
	])
	figura(c, manta, Color(0.72, 0.22, 0.20), 1.5)
	# Franja de la manta.
	c.draw_line(Vector2(-r * 0.8, r * 0.5), Vector2(r * 0.8, r * 0.5), Color(0.92, 0.85, 0.70), 2.0)

	# Cabeza.
	figura(c, elipse(Vector2(0, -r * 0.45), r * 0.42, r * 0.42), cuerpo, 1.5)

	# Sombrero de huaso: ala ancha y copa chata.
	figura(c, elipse(Vector2(0, -r * 0.70), r * 1.05, r * 0.24), Color(0.20, 0.17, 0.15), 1.5)
	figura(c, elipse(Vector2(0, -r * 0.92), r * 0.42, r * 0.26), Color(0.26, 0.22, 0.19), 1.5)

	# Mirada: dos puntos hacia donde camina.
	var ojo := Vector2(lado * r * 0.16, -r * 0.48)
	c.draw_circle(ojo, r * 0.07, BORDE)
	c.draw_circle(ojo + Vector2(lado * r * 0.20, 0), r * 0.07, BORDE)


# --- Enemigos ---------------------------------------------------------------

static func enemigo(c: CanvasItem, tipo: String, r: float, col: Color, lado: float) -> void:
	match tipo:
		"quiltro": _quiltro(c, r, col, lado)
		"borracho": _borracho(c, r, col)
		"momia": _momia(c, r, col)
		"ovni": _ovni(c, r, col)
		"gaviota": _gaviota(c, r, col, lado)
		"colo_colo": _colo_colo(c, r, col, lado)
		"trauco": _trauco(c, r, col)
		"invunche": _invunche(c, r, col)
		"aku_aku": _aku_aku(c, r, col)
		"moai": _moai(c, r, col)
		_: figura(c, elipse(Vector2.ZERO, r, r), col)


static func _quiltro(c: CanvasItem, r: float, col: Color, lado: float) -> void:
	# Perro callejero de perfil.
	c.draw_line(Vector2(-r * 0.9 * lado, 0), Vector2(-r * 1.5 * lado, -r * 0.7), col.darkened(0.2), 3.0)
	figura(c, elipse(Vector2.ZERO, r * 1.0, r * 0.66), col)
	for dx in [-0.4, 0.35]:
		c.draw_line(Vector2(r * dx, r * 0.5), Vector2(r * dx, r * 1.1), col.darkened(0.25), 3.0)
	var cabeza := Vector2(r * 0.85 * lado, -r * 0.35)
	figura(c, elipse(cabeza, r * 0.5, r * 0.45), col)
	# Orejas paradas.
	figura(c, PackedVector2Array([
		cabeza + Vector2(-r * 0.3, -r * 0.3), cabeza + Vector2(-r * 0.05, -r * 0.95),
		cabeza + Vector2(r * 0.15, -r * 0.28)]), col.darkened(0.25))
	figura(c, PackedVector2Array([
		cabeza + Vector2(r * 0.2, -r * 0.28), cabeza + Vector2(r * 0.45, -r * 0.85),
		cabeza + Vector2(r * 0.5, -r * 0.2)]), col.darkened(0.25))
	# Hocico y ojo.
	figura(c, elipse(cabeza + Vector2(r * 0.42 * lado, r * 0.12), r * 0.24, r * 0.18), col.darkened(0.15))
	c.draw_circle(cabeza + Vector2(r * 0.15 * lado, -r * 0.05), r * 0.09, BORDE)


static func _borracho(c: CanvasItem, r: float, col: Color) -> void:
	# Tio curado: panza, camisa abierta y una copa de terremoto.
	figura(c, elipse(Vector2(0, r * 0.15), r * 0.95, r * 0.85), col)
	figura(c, elipse(Vector2(0, -r * 0.75), r * 0.48, r * 0.48), Color(0.88, 0.72, 0.58))
	# Ojos entrecerrados.
	c.draw_line(Vector2(-r * 0.28, -r * 0.8), Vector2(-r * 0.08, -r * 0.8), BORDE, 2.0)
	c.draw_line(Vector2(r * 0.08, -r * 0.8), Vector2(r * 0.28, -r * 0.8), BORDE, 2.0)
	# Cachetes colorados.
	c.draw_circle(Vector2(-r * 0.34, -r * 0.62), r * 0.12, Color(0.90, 0.40, 0.40, 0.7))
	c.draw_circle(Vector2(r * 0.34, -r * 0.62), r * 0.12, Color(0.90, 0.40, 0.40, 0.7))
	# La copa.
	figura(c, PackedVector2Array([
		Vector2(r * 0.75, -r * 0.30), Vector2(r * 1.25, -r * 0.30),
		Vector2(r * 1.0, r * 0.15)]), Color(0.95, 0.85, 0.45))


static func _momia(c: CanvasItem, r: float, col: Color) -> void:
	# Momia chinchorro: cuerpo vendado y mascara oscura.
	figura(c, PackedVector2Array([
		Vector2(-r * 0.62, -r), Vector2(r * 0.62, -r),
		Vector2(r * 0.78, r), Vector2(-r * 0.78, r)]), col)
	for i in 4:
		var y := -r * 0.75 + r * 0.45 * i
		c.draw_line(Vector2(-r * 0.72, y), Vector2(r * 0.72, y), col.darkened(0.3), 2.0)
	# Brazos estirados hacia adelante.
	for s in [-1.0, 1.0]:
		figura(c, PackedVector2Array([
			Vector2(s * r * 0.55, -r * 0.52), Vector2(s * r * 1.30, -r * 0.34),
			Vector2(s * r * 1.30, -r * 0.02), Vector2(s * r * 0.55, -r * 0.18)]), col)
	figura(c, elipse(Vector2(0, -r * 0.95), r * 0.42, r * 0.38), Color(0.22, 0.18, 0.16))
	c.draw_circle(Vector2(-r * 0.15, -r * 0.98), r * 0.08, Color(0.95, 0.80, 0.30))
	c.draw_circle(Vector2(r * 0.15, -r * 0.98), r * 0.08, Color(0.95, 0.80, 0.30))


static func _ovni(c: CanvasItem, r: float, col: Color) -> void:
	# Platillo con cupula y luces.
	figura(c, elipse(Vector2(0, -r * 0.45), r * 0.55, r * 0.5), col.lightened(0.25))
	figura(c, elipse(Vector2.ZERO, r * 1.25, r * 0.42), col)
	for i in 5:
		var x := -r * 0.95 + r * 0.475 * i
		c.draw_circle(Vector2(x, r * 0.08), r * 0.12, Color(1.0, 0.95, 0.55))
	# Haz de luz.
	c.draw_colored_polygon(PackedVector2Array([
		Vector2(-r * 0.4, r * 0.35), Vector2(r * 0.4, r * 0.35),
		Vector2(r * 0.75, r * 1.5), Vector2(-r * 0.75, r * 1.5)]),
		Color(0.85, 1.0, 0.85, 0.18))


static func _gaviota(c: CanvasItem, r: float, col: Color, lado: float) -> void:
	# Gaviota porteña en pleno vuelo.
	figura(c, PackedVector2Array([
		Vector2(-r * 0.2, -r * 0.1), Vector2(-r * 1.6, -r * 0.85),
		Vector2(-r * 1.35, r * 0.1)]), col)
	figura(c, PackedVector2Array([
		Vector2(r * 0.2, -r * 0.1), Vector2(r * 1.6, -r * 0.85),
		Vector2(r * 1.35, r * 0.1)]), col)
	figura(c, elipse(Vector2.ZERO, r * 0.62, r * 0.46), col)
	var cabeza := Vector2(r * 0.5 * lado, -r * 0.38)
	figura(c, elipse(cabeza, r * 0.32, r * 0.30), col)
	# Pico naranjo.
	figura(c, PackedVector2Array([
		cabeza + Vector2(r * 0.22 * lado, -r * 0.06), cabeza + Vector2(r * 0.85 * lado, r * 0.02),
		cabeza + Vector2(r * 0.22 * lado, r * 0.16)]), Color(0.95, 0.62, 0.15))
	c.draw_circle(cabeza + Vector2(r * 0.08 * lado, -r * 0.06), r * 0.08, BORDE)


static func _colo_colo(c: CanvasItem, r: float, col: Color, lado: float) -> void:
	# Colo Colo: mito mitad serpiente, mitad gallo.
	var cola := PackedVector2Array()
	for i in 9:
		var t := float(i) / 8.0
		cola.append(Vector2(-r * 1.5 * lado * t, sin(t * PI * 1.8) * r * 0.42 + r * 0.3))
	c.draw_polyline(cola, col.darkened(0.15), 5.0)
	figura(c, elipse(Vector2.ZERO, r * 0.75, r * 0.62), col)
	var cabeza := Vector2(r * 0.62 * lado, -r * 0.42)
	figura(c, elipse(cabeza, r * 0.38, r * 0.34), col)
	# Cresta de gallo.
	figura(c, PackedVector2Array([
		cabeza + Vector2(-r * 0.2, -r * 0.28), cabeza + Vector2(-r * 0.05, -r * 0.8),
		cabeza + Vector2(r * 0.15, -r * 0.34), cabeza + Vector2(r * 0.3, -r * 0.72),
		cabeza + Vector2(r * 0.34, -r * 0.2)]), Color(0.88, 0.22, 0.22))
	# Pico.
	figura(c, PackedVector2Array([
		cabeza + Vector2(r * 0.26 * lado, 0), cabeza + Vector2(r * 0.78 * lado, r * 0.1),
		cabeza + Vector2(r * 0.26 * lado, r * 0.2)]), Color(0.95, 0.75, 0.20))
	c.draw_circle(cabeza + Vector2(r * 0.1 * lado, -r * 0.08), r * 0.09, Color(0.95, 0.90, 0.20))


static func _trauco(c: CanvasItem, r: float, col: Color) -> void:
	# Trauco: enano encorvado del bosque chilote, con hacha de piedra.
	figura(c, PackedVector2Array([
		Vector2(-r * 0.7, r), Vector2(r * 0.7, r),
		Vector2(r * 0.5, -r * 0.3), Vector2(-r * 0.5, -r * 0.3)]), col)
	figura(c, elipse(Vector2(0, -r * 0.62), r * 0.45, r * 0.42), Color(0.62, 0.50, 0.36))
	# Sombrero conico de quilineja.
	figura(c, PackedVector2Array([
		Vector2(-r * 0.62, -r * 0.85), Vector2(0, -r * 1.6), Vector2(r * 0.62, -r * 0.85)]),
		col.darkened(0.35))
	# Ojos hipnoticos.
	c.draw_circle(Vector2(-r * 0.17, -r * 0.66), r * 0.10, Color(0.95, 0.85, 0.25))
	c.draw_circle(Vector2(r * 0.17, -r * 0.66), r * 0.10, Color(0.95, 0.85, 0.25))
	# Hachita.
	c.draw_line(Vector2(r * 0.6, r * 0.3), Vector2(r * 1.1, -r * 0.5), Color(0.45, 0.32, 0.20), 3.0)
	figura(c, elipse(Vector2(r * 1.15, -r * 0.6), r * 0.25, r * 0.18), Color(0.65, 0.65, 0.68))


static func _invunche(c: CanvasItem, r: float, col: Color) -> void:
	# Invunche: el guardian deforme de la cueva chilota. La seña del mito es la
	# pierna derecha doblada y cosida sobre la espalda, asi que esa es la
	# silueta: encorvado, cabeza torcida y esa pierna levantada por detras.
	var piel := Color(0.70, 0.56, 0.48)

	# La pierna doblada sobre la espalda, por detras del cuerpo.
	figura(c, PackedVector2Array([
		Vector2(r * 0.15, r * 0.25), Vector2(r * 0.95, -r * 0.15),
		Vector2(r * 0.70, -r * 0.95), Vector2(r * 0.30, -r * 1.05),
		Vector2(r * 0.38, -r * 0.55), Vector2(-r * 0.10, -r * 0.10)]), col.darkened(0.30))
	# Pie al final de la pierna.
	figura(c, elipse(Vector2(r * 0.48, -r * 1.05), r * 0.30, r * 0.18), piel.darkened(0.20))

	# Torso encorvado.
	figura(c, PackedVector2Array([
		Vector2(-r * 0.72, r * 0.95), Vector2(r * 0.42, r * 0.95),
		Vector2(r * 0.30, -r * 0.20), Vector2(-r * 0.35, -r * 0.55),
		Vector2(-r * 0.80, -r * 0.05)]), col)

	# Brazo colgando hacia adelante.
	figura(c, PackedVector2Array([
		Vector2(-r * 0.62, -r * 0.15), Vector2(-r * 1.15, r * 0.35),
		Vector2(-r * 0.95, r * 0.70), Vector2(-r * 0.45, r * 0.30)]), col.darkened(0.12))
	figura(c, elipse(Vector2(-r * 1.08, r * 0.55), r * 0.20, r * 0.20), piel.darkened(0.15))

	# Cabeza torcida hacia el hombro.
	figura(c, elipse(Vector2(-r * 0.55, -r * 0.80), r * 0.44, r * 0.40), piel)
	# Un ojo grande abierto y otro cosido.
	c.draw_circle(Vector2(-r * 0.68, -r * 0.88), r * 0.15, Color(0.96, 0.94, 0.88))
	c.draw_circle(Vector2(-r * 0.70, -r * 0.88), r * 0.08, BORDE)
	c.draw_line(Vector2(-r * 0.34, -r * 0.92), Vector2(-r * 0.16, -r * 0.86), BORDE, 2.0)
	# Boca torcida.
	c.draw_line(Vector2(-r * 0.70, -r * 0.58), Vector2(-r * 0.28, -r * 0.66), BORDE, 2.0)


static func _aku_aku(c: CanvasItem, r: float, col: Color) -> void:
	# Espiritu pascuense: cuerpo flotante con borde ondulado.
	var puntos := PackedVector2Array()
	for i in 18:
		var a := TAU * float(i) / 18.0
		var radio := r * (1.0 + (0.18 if i % 2 == 0 else -0.10))
		if sin(a) > 0.4:
			radio *= 1.15
		puntos.append(Vector2(cos(a) * radio * 0.85, sin(a) * radio))
	figura(c, puntos, Color(col.r, col.g, col.b, 0.85))
	c.draw_circle(Vector2(-r * 0.28, -r * 0.2), r * 0.20, Color(0.98, 0.98, 1.0))
	c.draw_circle(Vector2(r * 0.28, -r * 0.2), r * 0.20, Color(0.98, 0.98, 1.0))
	c.draw_circle(Vector2(-r * 0.28, -r * 0.2), r * 0.10, BORDE)
	c.draw_circle(Vector2(r * 0.28, -r * 0.2), r * 0.10, BORDE)


static func _moai(c: CanvasItem, r: float, col: Color) -> void:
	# Moai: cabeza alargada, ceja pesada y nariz larga.
	figura(c, PackedVector2Array([
		Vector2(-r * 0.62, r), Vector2(r * 0.62, r),
		Vector2(r * 0.70, -r * 0.55), Vector2(r * 0.52, -r * 1.0),
		Vector2(-r * 0.52, -r * 1.0), Vector2(-r * 0.70, -r * 0.55)]), col, 2.0)
	# Ceja pesada.
	figura(c, PackedVector2Array([
		Vector2(-r * 0.60, -r * 0.55), Vector2(r * 0.60, -r * 0.55),
		Vector2(r * 0.55, -r * 0.32), Vector2(-r * 0.55, -r * 0.32)]), col.darkened(0.35), 0.0)
	# Ojos hundidos.
	figura(c, elipse(Vector2(-r * 0.30, -r * 0.16), r * 0.19, r * 0.13), Color(0.14, 0.12, 0.12), 0.0)
	figura(c, elipse(Vector2(r * 0.30, -r * 0.16), r * 0.19, r * 0.13), Color(0.14, 0.12, 0.12), 0.0)
	# Nariz larga.
	figura(c, PackedVector2Array([
		Vector2(-r * 0.14, -r * 0.12), Vector2(r * 0.14, -r * 0.12),
		Vector2(r * 0.20, r * 0.38), Vector2(-r * 0.20, r * 0.38)]), col.darkened(0.18), 0.0)
	# Boca recta.
	c.draw_line(Vector2(-r * 0.30, r * 0.62), Vector2(r * 0.30, r * 0.62), col.darkened(0.45), 3.0)
