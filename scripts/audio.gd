extends Node

# Singleton de audio (autoload "Audio"). Maneja la musica en loop y un pool de
# voces para los efectos.

const VOCES := 14

const EFECTOS := {
	"disparo": preload("res://audio/disparo.wav"),
	"impacto": preload("res://audio/impacto.wav"),
	"muerte": preload("res://audio/muerte.wav"),
	"xp": preload("res://audio/xp.wav"),
	"nivel": preload("res://audio/nivel.wav"),
	"dano": preload("res://audio/dano.wav"),
	"jefe": preload("res://audio/jefe.wav"),
}

# Segundos minimos entre dos repeticiones del mismo efecto. Sin esto, un
# cacerolazo que pega a 40 enemigos dispara 40 sonidos en el mismo frame y
# suena a ruido blanco.
const ESPERA_MINIMA := {
	"disparo": 0.05,
	"impacto": 0.06,
	"muerte": 0.05,
	"xp": 0.04,
	"nivel": 0.0,
	"dano": 0.15,
	"jefe": 0.0,
}

var volumen_musica := 0.75: set = _set_volumen_musica
var volumen_efectos := 0.85

var _musica: AudioStreamPlayer
var _voces: Array[AudioStreamPlayer] = []
var _siguiente := 0
var _ultima_vez := {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	_musica = AudioStreamPlayer.new()
	_musica.stream = _preparar_loop(preload("res://audio/musica_fonda.wav"))
	_musica.volume_db = linear_to_db(volumen_musica)
	add_child(_musica)

	for i in VOCES:
		var voz := AudioStreamPlayer.new()
		add_child(voz)
		_voces.append(voz)


func _preparar_loop(stream: AudioStreamWAV) -> AudioStreamWAV:
	# El importador deja el WAV sin loop; se activa aca para no depender de
	# configuracion del editor.
	var s := stream.duplicate() as AudioStreamWAV
	var bytes_por_muestra := 2 if s.format == AudioStreamWAV.FORMAT_16_BITS else 1
	var canales := 2 if s.stereo else 1
	s.loop_mode = AudioStreamWAV.LOOP_FORWARD
	s.loop_begin = 0
	s.loop_end = s.data.size() / (bytes_por_muestra * canales)
	return s


func tocar_musica() -> void:
	if not _musica.playing:
		_musica.play()


func parar_musica() -> void:
	_musica.stop()


func sonar(nombre: String, tono := 1.0, ganancia := 1.0) -> void:
	if not EFECTOS.has(nombre):
		return

	var ahora := Time.get_ticks_msec() / 1000.0
	var espera: float = ESPERA_MINIMA.get(nombre, 0.05)
	if espera > 0.0 and ahora - float(_ultima_vez.get(nombre, -99.0)) < espera:
		return
	_ultima_vez[nombre] = ahora

	var voz := _voces[_siguiente]
	_siguiente = (_siguiente + 1) % VOCES
	voz.stream = EFECTOS[nombre]
	voz.pitch_scale = clampf(tono, 0.1, 4.0)
	voz.volume_db = linear_to_db(clampf(volumen_efectos * ganancia, 0.001, 1.0))
	voz.play()


func _set_volumen_musica(valor: float) -> void:
	volumen_musica = clampf(valor, 0.0, 1.0)
	if _musica != null:
		_musica.volume_db = linear_to_db(maxf(volumen_musica, 0.001))
