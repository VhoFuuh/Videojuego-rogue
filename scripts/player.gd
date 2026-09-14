class_name Player
extends CharacterBody2D

const RADIO := 14.0
const TIEMPO_INVULNERABLE := 0.5
# Tope duro: sin esto, apilar mejoras de velocidad deja atras a todos los
# enemigos y la partida se vuelve imposible de perder.
const VELOCIDAD_MAXIMA := 340.0

signal murio
signal vida_cambio(actual: int, maxima: int)
signal xp_cambio(actual: int, necesaria: int, nivel: int)
signal subio_nivel

var vida_maxima := 110
var vida := 110
var velocidad := 230.0
var mult_dano := 1.0
var mult_vel_ataque := 1.0
var radio_recogida := 130.0
var regen := 0.0

var nivel := 1
var xp := 0
var xp_necesaria := 3

var armas := {}

var _invulnerable := 0.0
var _acumulador_regen := 0.0
var _flash := 0.0
var _mirando := Vector2.RIGHT
var _lado := 1.0
var _tinte := Color(1, 1, 1)


func _ready() -> void:
	add_to_group("jugador")
	collision_layer = 1
	collision_mask = 0

	var forma := CollisionShape2D.new()
	var circulo := CircleShape2D.new()
	circulo.radius = RADIO
	forma.shape = circulo
	add_child(forma)

	_aplicar_permanentes()
	agregar_arma("anticucho")


func _aplicar_permanentes() -> void:
	# Lo comprado en la fonda entre partidas. Se aplica antes de empezar.
	vida_maxima += 15 * Guardado.nivel_de("vida_campo")
	vida = vida_maxima
	mult_dano *= 1.0 + 0.08 * Guardado.nivel_de("buena_mano")
	velocidad = minf(
		velocidad * (1.0 + 0.05 * Guardado.nivel_de("piernas")), VELOCIDAD_MAXIMA)
	radio_recogida += 25.0 * Guardado.nivel_de("bolsillo")
	regen += 0.25 * Guardado.nivel_de("once")
	mult_vel_ataque *= 1.0 + 0.08 * Guardado.nivel_de("buen_ojo")


func _physics_process(delta: float) -> void:
	var direccion := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direccion * velocidad
	if direccion != Vector2.ZERO:
		_mirando = direccion
		if absf(direccion.x) > 0.1 and signf(direccion.x) != _lado:
			_lado = signf(direccion.x)
			queue_redraw()
	move_and_slide()

	if _invulnerable > 0.0:
		_invulnerable -= delta
	if _flash > 0.0:
		_flash -= delta
	_actualizar_tinte()

	if regen > 0.0 and vida < vida_maxima:
		_acumulador_regen += regen * delta
		if _acumulador_regen >= 1.0:
			var curado := int(_acumulador_regen)
			_acumulador_regen -= curado
			vida = min(vida_maxima, vida + curado)
			vida_cambio.emit(vida, vida_maxima)


func _draw() -> void:
	draw_colored_polygon(
		Dibujos.elipse(Vector2(0, RADIO * 1.05), RADIO * 0.85, RADIO * 0.28),
		Color(0, 0, 0, 0.25))

	Dibujos.huaso(self, RADIO, Color(0.90, 0.76, 0.60), Vector2(_lado, 0))


func _actualizar_tinte() -> void:
	var tinte := Color(1, 1, 1)
	if _flash > 0.0:
		tinte = Color(1.9, 0.8, 0.8)
	elif _invulnerable > 0.0:
		tinte = Color(0.75, 0.75, 0.80)
	if tinte != _tinte:
		_tinte = tinte
		modulate = tinte


func recibir_dano(cantidad: int) -> void:
	if _invulnerable > 0.0 or vida <= 0:
		return
	vida -= cantidad
	Audio.sonar("dano")
	_invulnerable = TIEMPO_INVULNERABLE
	_flash = 0.15
	vida_cambio.emit(max(vida, 0), vida_maxima)
	if vida <= 0:
		murio.emit()


func ganar_xp(cantidad: int) -> void:
	xp += cantidad
	while xp >= xp_necesaria:
		xp -= xp_necesaria
		nivel += 1
		xp_necesaria = int(xp_necesaria * 1.25) + 2
		Audio.sonar("nivel")
		subio_nivel.emit()
	xp_cambio.emit(xp, xp_necesaria, nivel)


func agregar_arma(id: String) -> void:
	if armas.has(id):
		armas[id].nivel += 1
		return
	var arma: Node2D
	match id:
		"anticucho":
			arma = preload("res://scripts/weapons/anticucho.gd").new()
		"cacerola":
			arma = preload("res://scripts/weapons/cacerola.gd").new()
		"volantin":
			arma = preload("res://scripts/weapons/volantin.gd").new()
		_:
			return
	arma.name = id
	armas[id] = arma
	add_child(arma)


func aplicar_mejora(mejora: Dictionary) -> void:
	match mejora.id:
		"piscola":
			velocidad = minf(velocidad * 1.15, VELOCIDAD_MAXIMA)
		"pebre":
			mult_dano *= 1.20
		"empanada":
			vida_maxima += 20
			vida = min(vida_maxima, vida + 30)
		"mote":
			regen += 0.6
		"hilo_curado":
			mult_vel_ataque *= 1.20
		"iman":
			radio_recogida += 50.0
		"zapatillas":
			velocidad = minf(velocidad * 1.12, VELOCIDAD_MAXIMA)
			vida_maxima += 10
			vida += 10
		"anticucho", "cacerola", "volantin":
			agregar_arma(mejora.id)
	vida_cambio.emit(vida, vida_maxima)
