class_name Enemigo
extends Node2D

# No usa fisica: con cientos de enemigos en pantalla, las colisiones entre ellos
# se comian el 95% del tiempo de cada frame. Se mueven a mano y el contacto con
# el jugador se resuelve por distancia.

const INTERVALO_DANO := 0.6
const DISTANCIA_OLVIDO := 1600.0

signal murio(posicion: Vector2, xp: int)

var tipo := "quiltro"
var vida := 10
var velocidad := 120.0
var dano := 6
var radio := 10.0
var color := Color.WHITE
var xp_valor := 1

var _jugador: Player
var _espera_dano := 0.0
var _flash := 0.0


func _ready() -> void:
	add_to_group("enemigos")


func configurar(id: String, escala_vida: float, escala_dano: float, escala_velocidad: float) -> void:
	var d: Dictionary = Data.ENEMIGOS[id]
	tipo = id
	vida = int(d.vida * escala_vida)
	# Variacion por enemigo: sin esto la horda avanza como un bloque perfecto.
	velocidad = d.velocidad * escala_velocidad * randf_range(0.88, 1.12)
	dano = int(d.dano * escala_dano)
	radio = d.radio
	color = d.color
	xp_valor = d.xp


func _process(delta: float) -> void:
	if _jugador == null or not is_instance_valid(_jugador):
		_jugador = get_tree().get_first_node_in_group("jugador") as Player
		if _jugador == null:
			return

	var hacia: Vector2 = _jugador.global_position - global_position
	var distancia := hacia.length()
	if distancia > DISTANCIA_OLVIDO:
		queue_free()
		return

	if distancia > 0.1:
		global_position += hacia / distancia * velocidad * delta

	if _espera_dano > 0.0:
		_espera_dano -= delta
	elif distancia <= radio + Player.RADIO:
		_espera_dano = INTERVALO_DANO
		_jugador.recibir_dano(dano)

	if _flash > 0.0:
		_flash -= delta
		queue_redraw()


func _draw() -> void:
	var c := Color(1, 1, 1) if _flash > 0.0 else color
	draw_circle(Vector2.ZERO, radio, c)
	draw_arc(Vector2.ZERO, radio, 0.0, TAU, 20, c.darkened(0.4), 2.0)


func recibir_dano(cantidad: int) -> void:
	if vida <= 0:
		return
	vida -= cantidad
	_flash = 0.08
	queue_redraw()
	if vida <= 0:
		murio.emit(global_position, xp_valor)
		queue_free()
