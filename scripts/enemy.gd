class_name Enemigo
extends Node2D

# No usa fisica: con cientos de enemigos en pantalla, las colisiones entre ellos
# se comian el 95% del tiempo de cada frame. Se mueven a mano y el contacto con
# el jugador se resuelve por distancia.

const INTERVALO_DANO := 0.6
const DISTANCIA_OLVIDO := 1600.0

# Ciclo de embestida de los jefes: primero avisan, despues cargan.
const ESPERA_EMBESTIDA := 5.0
const AVISO_EMBESTIDA := 0.6
const DURACION_EMBESTIDA := 0.85
const VELOCIDAD_EMBESTIDA := 3.4

signal murio(posicion: Vector2, xp: int, lucas: int)
signal vida_jefe_cambio(actual: int, maxima: int)

var tipo := "quiltro"
var figura := "quiltro"
var vida := 10
var vida_maxima := 10
var velocidad := 120.0
var dano := 6
var radio := 10.0
var color := Color.WHITE
var xp_valor := 1
var lucas := 0
var es_jefe := false

var _jugador: Player
var _espera_dano := 0.0
var _flash := 0.0
var _lado := 1.0
var _tinte := Color(1, 1, 1)

var _espera_embestida := ESPERA_EMBESTIDA
var _aviso := 0.0
var _embistiendo := 0.0
var _dir_embestida := Vector2.ZERO


func _ready() -> void:
	add_to_group("enemigos")
	if es_jefe:
		add_to_group("jefes")


func configurar(id: String, escala_vida: float, escala_dano: float, escala_velocidad: float) -> void:
	var d: Dictionary = Data.ENEMIGOS[id]
	tipo = id
	figura = id
	vida = int(d.vida * escala_vida)
	vida_maxima = vida
	# Variacion por enemigo: sin esto la horda avanza como un bloque perfecto.
	velocidad = d.velocidad * escala_velocidad * randf_range(0.88, 1.12)
	dano = int(d.dano * escala_dano)
	radio = d.radio
	color = d.color
	xp_valor = d.xp
	# Los enemigos comunes tambien dejan lucas: sin eso la meta-progresion
	# dependeria solo de llegar a los jefes.
	lucas = d.xp


func configurar_jefe(indice: int, escala: float) -> void:
	var d: Dictionary = Data.JEFES[indice]
	es_jefe = true
	tipo = "jefe"
	figura = d.figura
	vida = int(d.vida * escala)
	vida_maxima = vida
	velocidad = d.velocidad
	dano = d.dano
	radio = d.radio
	color = d.color
	xp_valor = d.xp
	lucas = d.lucas


func _process(delta: float) -> void:
	if _jugador == null or not is_instance_valid(_jugador):
		_jugador = get_tree().get_first_node_in_group("jugador") as Player
		if _jugador == null:
			return

	var hacia: Vector2 = _jugador.global_position - global_position
	var distancia := hacia.length()
	# Los jefes nunca se descartan: si no, bastaria arrancar para saltarselos.
	if distancia > DISTANCIA_OLVIDO and not es_jefe:
		queue_free()
		return

	if es_jefe:
		_mover_jefe(delta, hacia, distancia)
	elif distancia > 0.1:
		global_position += hacia / distancia * velocidad * delta

	# Voltear con scale.x es una transformacion: no rehace el dibujo. El margen
	# de 8 px evita que un enemigo encima del jugador voltee en cada frame.
	if absf(hacia.x) > 8.0:
		var lado_nuevo := signf(hacia.x)
		if lado_nuevo != _lado:
			_lado = lado_nuevo
			scale.x = _lado

	if _espera_dano > 0.0:
		_espera_dano -= delta
	elif distancia <= radio + Player.RADIO:
		_espera_dano = INTERVALO_DANO
		_jugador.recibir_dano(dano)

	if _flash > 0.0:
		_flash -= delta
	_actualizar_tinte()


func _mover_jefe(delta: float, hacia: Vector2, distancia: float) -> void:
	if _aviso > 0.0:
		# Se planta y avisa antes de cargar: un jefe que embiste sin telegrafiar
		# se siente injusto.
		_aviso -= delta
		if _aviso <= 0.0:
			_embistiendo = DURACION_EMBESTIDA
			_dir_embestida = hacia.normalized()
		return

	if _embistiendo > 0.0:
		_embistiendo -= delta
		global_position += _dir_embestida * velocidad * VELOCIDAD_EMBESTIDA * delta
		return

	_espera_embestida -= delta
	if _espera_embestida <= 0.0:
		_espera_embestida = ESPERA_EMBESTIDA
		_aviso = AVISO_EMBESTIDA
		return

	if distancia > 0.1:
		global_position += hacia / distancia * velocidad * delta


func _actualizar_tinte() -> void:
	# El destello se hace con modulate, NO redibujando. Rehacer los poligonos
	# de cada enemigo golpeado costaba 7.9 ms por frame con 240 en pantalla;
	# con modulate el costo es cero porque no se reconstruye el dibujo.
	var tinte := Color(1, 1, 1)
	if _flash > 0.0:
		tinte = Color(1.8, 1.8, 1.8)
	elif _aviso > 0.0:
		tinte = Color(1.5, 1.3, 1.3)
	elif _embistiendo > 0.0:
		tinte = Color(1.25, 1.15, 1.15)
	if tinte != _tinte:
		_tinte = tinte
		modulate = tinte


func _draw() -> void:
	# Sombra: ancla la figura al suelo, si no parece flotando.
	draw_colored_polygon(
		Dibujos.elipse(Vector2(0, radio * 0.95), radio * 0.8, radio * 0.25),
		Color(0, 0, 0, 0.22))

	if es_jefe:
		draw_arc(Vector2.ZERO, radio * 1.15, 0.0, TAU, 32,
			Color(0.95, 0.82, 0.30, 0.55), 3.0)
	# Siempre se dibuja mirando a la derecha; el volteo lo hace scale.x.
	Dibujos.enemigo(self, figura, radio, color, 1.0)


func recibir_dano(cantidad: int) -> void:
	if vida <= 0:
		return
	vida -= cantidad
	_flash = 0.08
	if es_jefe:
		vida_jefe_cambio.emit(max(vida, 0), vida_maxima)
	if vida <= 0:
		Audio.sonar("muerte", randf_range(0.85, 1.15), 0.7)
		murio.emit(global_position, xp_valor, lucas)
		queue_free()
	else:
		Audio.sonar("impacto", randf_range(0.9, 1.2), 0.45)
