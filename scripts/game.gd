extends Node2D

# Orquestador de la partida: crea al jugador, genera oleadas, sube la dificultad,
# cambia de bioma y maneja las pantallas de mejora y de derrota.

const MAX_ENEMIGOS := 350
const MARGEN_APARICION := 70.0
const ZOOM := 1.5
const TAMANO_CELDA := 64.0

const AVISO_JEFE := 25.0

var tiempo := 0.0
var indice_bioma := -1
var lucas := 0
var jefes_derrotados := 0

var _jefe_invocado_en := -1

var _jugador: Player
var _camara: Camera2D
var _hud: Hud
var _menu: MenuMejoras
var _pausa: MenuPausa
var _pantalla_derrota: CanvasLayer

var _espera_aparicion := 0.0
var _mejoras_pendientes := 0
var _terminado := false


func _ready() -> void:
	_jugador = preload("res://scripts/player.gd").new()
	add_child(_jugador)

	_camara = Camera2D.new()
	_camara.zoom = Vector2(ZOOM, ZOOM)
	_camara.position_smoothing_enabled = true
	_camara.position_smoothing_speed = 8.0
	_jugador.add_child(_camara)

	_hud = preload("res://scripts/ui/hud.gd").new()
	add_child(_hud)

	_menu = preload("res://scripts/ui/level_up_menu.gd").new()
	add_child(_menu)

	_pausa = preload("res://scripts/ui/pause_menu.gd").new()
	add_child(_pausa)
	_pausa.continuar.connect(_reanudar)
	_pausa.salir.connect(volver_a_la_fonda)

	_jugador.vida_cambio.connect(_hud.set_vida)
	_jugador.xp_cambio.connect(_hud.set_xp)
	_jugador.subio_nivel.connect(_on_subio_nivel)
	_jugador.murio.connect(_on_jugador_murio)
	_menu.elegida.connect(_on_mejora_elegida)

	_hud.set_vida(_jugador.vida, _jugador.vida_maxima)
	_hud.set_xp(_jugador.xp, _jugador.xp_necesaria, _jugador.nivel)
	_cambiar_bioma(0)
	_oleada_inicial()
	Audio.tocar_musica()


func _process(delta: float) -> void:
	if _terminado:
		if Input.is_action_just_pressed("restart"):
			get_tree().paused = false
			get_tree().reload_current_scene()
		elif Input.is_action_just_pressed("ui_cancel"):
			volver_a_la_fonda()
		return

	# No se puede pausar mientras se elige mejora: ya esta pausado ahi.
	if Input.is_action_just_pressed("ui_cancel") and not _menu.visible:
		get_tree().paused = true
		_pausa.mostrar()
		return

	tiempo += delta
	_hud.set_tiempo(tiempo)
	queue_redraw()

	var bioma_actual := mini(int(tiempo / Data.DURACION_BIOMA), Data.BIOMAS.size() - 1)
	if bioma_actual != indice_bioma:
		_cambiar_bioma(bioma_actual)

	# El jefe aparece antes de que termine el bioma: es el climax de la etapa.
	var fin_bioma := float(indice_bioma + 1) * Data.DURACION_BIOMA
	if _jefe_invocado_en != indice_bioma and tiempo >= fin_bioma - AVISO_JEFE:
		_invocar_jefe()

	_espera_aparicion -= delta
	if _espera_aparicion <= 0.0:
		_espera_aparicion = intervalo_aparicion()
		_generar_oleada()


# --- Dificultad -------------------------------------------------------------
# Todo escala con el tiempo: entre mas dura la run, mas apretado se pone.

func escala_vida() -> float:
	return 1.0 + tiempo / 60.0 * 0.35


func escala_dano() -> float:
	return 1.0 + tiempo / 90.0 * 0.25


func escala_velocidad() -> float:
	# Los enemigos tambien se aceleran: si no, al acumular mejoras de velocidad el
	# jugador los deja a todos atras y se vuelve invencible sin matar nada.
	return 1.0 + tiempo / 120.0 * 0.10


func intervalo_aparicion() -> float:
	return maxf(0.16, 1.0 - tiempo * 0.005)


func enemigos_por_oleada() -> int:
	return 1 + int(tiempo / 35.0)


# --- Generacion de enemigos -------------------------------------------------

func _generar_oleada() -> void:
	var vivos := get_tree().get_nodes_in_group("enemigos").size()
	if vivos >= MAX_ENEMIGOS:
		return

	var tipos: Array = Data.BIOMAS[indice_bioma].enemigos
	for i in enemigos_por_oleada():
		if vivos + i >= MAX_ENEMIGOS:
			break
		var enemigo := Enemigo.new()
		enemigo.configurar(tipos.pick_random(), escala_vida(), escala_dano(), escala_velocidad())
		enemigo.global_position = _punto_fuera_de_pantalla()
		enemigo.murio.connect(_on_enemigo_murio)
		add_child(enemigo)


func _punto_fuera_de_pantalla() -> Vector2:
	# Justo afuera del borde visible: si aparecen mas lejos el jugador se queda
	# esperando y los primeros segundos se sienten vacios.
	# El zoom achica el area visible: sin dividir, apareceria todo muy lejos.
	var mitad := get_viewport_rect().size * 0.5 / ZOOM + Vector2(MARGEN_APARICION, MARGEN_APARICION)

	var angulo := randf() * TAU
	# La mayoria aparece hacia donde el jugador corre: si no, arrancar en linea
	# recta seria una estrategia perfecta y el juego se vuelve imposible de perder.
	if _jugador.velocity.length() > 10.0 and randf() < 0.65:
		angulo = _jugador.velocity.angle() + randf_range(-1.0, 1.0)

	var direccion := Vector2(cos(angulo), sin(angulo))
	var escala_x := mitad.x / absf(direccion.x) if absf(direccion.x) > 0.001 else INF
	var escala_y := mitad.y / absf(direccion.y) if absf(direccion.y) > 0.001 else INF
	return _jugador.global_position + direccion * minf(escala_x, escala_y)


func _oleada_inicial() -> void:
	# Accion inmediata: el jugador pelea desde el primer segundo, sin tutorial.
	var tipos: Array = Data.BIOMAS[indice_bioma].enemigos
	for i in 8:
		var angulo := TAU * float(i) / 8.0
		var enemigo := Enemigo.new()
		enemigo.configurar(tipos.pick_random(), 1.0, 1.0, 1.0)
		enemigo.global_position = _jugador.global_position + Vector2(cos(angulo), sin(angulo)) * 330.0
		enemigo.murio.connect(_on_enemigo_murio)
		add_child(enemigo)


func _invocar_jefe() -> void:
	_jefe_invocado_en = indice_bioma
	var d: Dictionary = Data.JEFES[indice_bioma]

	var jefe := Enemigo.new()
	jefe.configurar_jefe(indice_bioma, 1.0 + tiempo / 600.0 * 0.5)
	jefe.global_position = _punto_fuera_de_pantalla()
	jefe.murio.connect(_on_enemigo_murio)
	jefe.murio.connect(_on_jefe_murio.unbind(3))
	jefe.vida_jefe_cambio.connect(_hud.set_vida_jefe)
	add_child(jefe)

	_hud.mostrar_jefe(d.nombre, jefe.vida)
	_hud.anunciar(d.nombre)
	Audio.sonar("jefe")


func _on_jefe_murio() -> void:
	jefes_derrotados += 1
	_hud.ocultar_jefe()
	_hud.anunciar("¡Caiste, %s!" % Data.JEFES[indice_bioma].nombre)


func _on_enemigo_murio(posicion: Vector2, xp: int, lucas_ganadas: int) -> void:
	if lucas_ganadas > 0:
		lucas += lucas_ganadas
		_hud.set_lucas(lucas)

	var orbe := OrbeXP.new()
	orbe.valor = xp
	orbe.global_position = posicion
	add_child(orbe)


# --- Biomas -----------------------------------------------------------------

func _cambiar_bioma(indice: int) -> void:
	indice_bioma = indice
	var bioma: Dictionary = Data.BIOMAS[indice]
	RenderingServer.set_default_clear_color(bioma.fondo)
	_hud.set_bioma(bioma.nombre)
	_hud.anunciar(bioma.nombre)


func _draw() -> void:
	if not is_instance_valid(_jugador):
		return
	# Cuadricula del suelo: sin esto no se nota que el jugador se mueve.
	var bioma: Dictionary = Data.BIOMAS[indice_bioma]
	var centro := _jugador.global_position
	var extension := Vector2(900, 620)
	var inicio := ((centro - extension) / TAMANO_CELDA).floor() * TAMANO_CELDA
	var fin := centro + extension
	var color: Color = bioma.suelo

	var x := inicio.x
	while x < fin.x:
		draw_line(Vector2(x, inicio.y), Vector2(x, fin.y), color, 1.0)
		x += TAMANO_CELDA
	var y := inicio.y
	while y < fin.y:
		draw_line(Vector2(inicio.x, y), Vector2(fin.x, y), color, 1.0)
		y += TAMANO_CELDA


# --- Mejoras ----------------------------------------------------------------

func _on_subio_nivel() -> void:
	_mejoras_pendientes += 1
	if not _menu.visible:
		_mostrar_mejoras()


func _mostrar_mejoras() -> void:
	get_tree().paused = true
	var opciones := Data.MEJORAS.duplicate()
	opciones.shuffle()
	_menu.mostrar(opciones.slice(0, 3))


func _on_mejora_elegida(mejora: Dictionary) -> void:
	_jugador.aplicar_mejora(mejora)
	_mejoras_pendientes -= 1
	if _mejoras_pendientes > 0:
		_mostrar_mejoras()
	else:
		_menu.ocultar()
		get_tree().paused = false


func _reanudar() -> void:
	_pausa.ocultar()
	get_tree().paused = false


func volver_a_la_fonda() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/fonda.tscn")


# --- Derrota ----------------------------------------------------------------

func _on_jugador_murio() -> void:
	if _terminado:
		return
	_terminado = true
	var nivel_final := _jugador.nivel
	_jugador.queue_free()
	_hud.ocultar_jefe()
	Guardado.registrar_partida(lucas, tiempo, nivel_final, jefes_derrotados)

	_pantalla_derrota = CanvasLayer.new()
	_pantalla_derrota.layer = 30
	add_child(_pantalla_derrota)

	var fondo := ColorRect.new()
	fondo.color = Color(0, 0, 0, 0.62)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pantalla_derrota.add_child(fondo)

	var columna := VBoxContainer.new()
	columna.set_anchors_preset(Control.PRESET_CENTER)
	columna.grow_horizontal = Control.GROW_DIRECTION_BOTH
	columna.grow_vertical = Control.GROW_DIRECTION_BOTH
	columna.alignment = BoxContainer.ALIGNMENT_CENTER
	columna.add_theme_constant_override("separation", 16)
	_pantalla_derrota.add_child(columna)

	var lineas := [
		["SE ACABO LA FONDA", 46],
		["Sobreviviste %d:%02d en %s" % [
			int(tiempo) / 60, int(tiempo) % 60, Data.BIOMAS[indice_bioma].nombre], 22],
		["Llegaste a nivel %d" % nivel_final, 22],
		["Ganaste $ %d lucas" % lucas, 24],
		["R para otra run    ·    ESC para volver a la fonda", 18],
	]
	for linea in lineas:
		var etiqueta := Label.new()
		etiqueta.text = linea[0]
		etiqueta.add_theme_font_size_override("font_size", linea[1])
		etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		columna.add_child(etiqueta)
