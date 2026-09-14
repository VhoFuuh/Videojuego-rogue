extends Node

# Singleton de guardado (autoload "Guardado"). Guarda en user://, que en Linux
# queda en ~/.local/share/godot/app_userdata/ y en Windows en %APPDATA%.

const RUTA := "user://guardado.json"

var lucas := 0
var permanentes := {}
var mejor_tiempo := 0.0
var mejor_nivel := 0
var jefes_derrotados := 0
var partidas := 0
var personajes := ["huaso"]  # desbloqueados
var personaje := "huaso"     # el elegido para la proxima partida


func _ready() -> void:
	cargar()


func datos_personaje(id: String) -> Dictionary:
	for p in Data.PERSONAJES:
		if p.id == id:
			return p
	return Data.PERSONAJES[0]


func personaje_actual() -> Dictionary:
	return datos_personaje(personaje)


func tiene_personaje(id: String) -> bool:
	return personajes.has(id)


func desbloquear_personaje(p: Dictionary) -> bool:
	if tiene_personaje(p.id) or lucas < int(p.costo):
		return false
	lucas -= int(p.costo)
	personajes.append(p.id)
	guardar()
	return true


func elegir_personaje(id: String) -> void:
	if not tiene_personaje(id):
		return
	personaje = id
	guardar()


func nivel_de(id: String) -> int:
	return int(permanentes.get(id, 0))


func costo_de(mejora: Dictionary) -> int:
	# Cada nivel cuesta mas que el anterior.
	return int(mejora.costo_base) * (nivel_de(mejora.id) + 1)


func al_maximo(mejora: Dictionary) -> bool:
	return nivel_de(mejora.id) >= int(mejora.max)


func puede_comprar(mejora: Dictionary) -> bool:
	return not al_maximo(mejora) and lucas >= costo_de(mejora)


func comprar(mejora: Dictionary) -> bool:
	if not puede_comprar(mejora):
		return false
	lucas -= costo_de(mejora)
	permanentes[mejora.id] = nivel_de(mejora.id) + 1
	guardar()
	return true


func registrar_partida(lucas_ganadas: int, tiempo: float, nivel: int, jefes: int) -> void:
	lucas += lucas_ganadas
	partidas += 1
	jefes_derrotados += jefes
	mejor_tiempo = maxf(mejor_tiempo, tiempo)
	mejor_nivel = maxi(mejor_nivel, nivel)
	guardar()


func guardar() -> void:
	var f := FileAccess.open(RUTA, FileAccess.WRITE)
	if f == null:
		push_warning("No se pudo guardar en %s" % RUTA)
		return
	f.store_string(JSON.stringify({
		"lucas": lucas,
		"permanentes": permanentes,
		"mejor_tiempo": mejor_tiempo,
		"mejor_nivel": mejor_nivel,
		"jefes_derrotados": jefes_derrotados,
		"partidas": partidas,
		"personajes": personajes,
		"personaje": personaje,
	}, "\t"))
	f.close()


func cargar() -> void:
	if not FileAccess.file_exists(RUTA):
		return
	var f := FileAccess.open(RUTA, FileAccess.READ)
	if f == null:
		return
	var texto := f.get_as_text()
	f.close()

	var datos = JSON.parse_string(texto)
	# Un guardado corrupto no debe impedir jugar: se ignora y se parte de cero.
	if typeof(datos) != TYPE_DICTIONARY:
		push_warning("Guardado ilegible, se empieza de cero")
		return

	lucas = int(datos.get("lucas", 0))
	mejor_tiempo = float(datos.get("mejor_tiempo", 0.0))
	mejor_nivel = int(datos.get("mejor_nivel", 0))
	jefes_derrotados = int(datos.get("jefes_derrotados", 0))
	partidas = int(datos.get("partidas", 0))

	# Solo se aceptan personajes que existan hoy; el huaso siempre esta.
	personajes = ["huaso"]
	var lista = datos.get("personajes", [])
	if typeof(lista) == TYPE_ARRAY:
		for p in Data.PERSONAJES:
			if p.id != "huaso" and lista.has(p.id):
				personajes.append(p.id)
	personaje = str(datos.get("personaje", "huaso"))
	if not tiene_personaje(personaje):
		personaje = "huaso"

	permanentes = {}
	var guardadas = datos.get("permanentes", {})
	if typeof(guardadas) == TYPE_DICTIONARY:
		# Solo se aceptan ids que existan hoy, por si el guardado es de una
		# version vieja del juego.
		for mejora in Data.PERMANENTES:
			if guardadas.has(mejora.id):
				permanentes[mejora.id] = clampi(
					int(guardadas[mejora.id]), 0, int(mejora.max))


func borrar_todo() -> void:
	lucas = 0
	permanentes = {}
	mejor_tiempo = 0.0
	mejor_nivel = 0
	jefes_derrotados = 0
	partidas = 0
	personajes = ["huaso"]
	personaje = "huaso"
	guardar()
