extends Node

# Prueba las siete recetas de evolucion. El bot del autoplay elige al azar y
# casi nunca llega a evolucionar, asi que sin esta prueba el sistema quedaria
# sin verificar.

var _fallos := 0


func _ready() -> void:
	await get_tree().process_frame
	print("--- evoluciones ---")

	for evo in Data.EVOLUCIONES:
		await _probar(evo)

	print("--- cupos ---")
	await _probar_cupos()

	print("\n%s" % ("TODO OK" if _fallos == 0 else "FALLOS: %d" % _fallos))
	get_tree().quit(1 if _fallos > 0 else 0)


func _revisar(condicion: bool, texto: String) -> void:
	if not condicion:
		_fallos += 1
	print("  %s %s" % ["ok  " if condicion else "FALLA", texto])


func _nuevo_jugador() -> Player:
	var j: Player = preload("res://scripts/player.gd").new()
	add_child(j)
	await get_tree().process_frame
	return j


func _probar(evo: Dictionary) -> void:
	var j := await _nuevo_jugador()

	j.agregar_arma(evo.arma)
	await get_tree().process_frame
	var arma: Arma = j.armas[evo.arma]

	# Todavia no deberia poder: falta subir arma y pasiva.
	_revisar(not j.puede_evolucionar(evo), "%s bloqueada al principio" % evo.nombre)

	while not arma.al_maximo():
		j.agregar_arma(evo.arma)
	_revisar(not j.puede_evolucionar(evo),
		"%s sigue bloqueada con solo el arma al maximo" % evo.nombre)

	var tope := int(Data.PASIVAS[evo.pasiva].max)
	for i in tope:
		j.subir_pasiva(evo.pasiva)
	_revisar(j.puede_evolucionar(evo), "%s habilitada con arma y pasiva al maximo" % evo.nombre)

	var antes := _medir(arma)
	j.aplicar_opcion({"tipo": "evolucion", "arma": evo.arma})
	await get_tree().process_frame
	var despues := _medir(arma)

	_revisar(arma.evolucionada, "%s queda marcada como evolucionada" % evo.nombre)
	_revisar(despues > antes, "%s sube su potencia (%d -> %d)" % [evo.nombre, antes, despues])
	_revisar(not j.puede_evolucionar(evo), "%s no se puede repetir" % evo.nombre)

	j.free()


# Medida gruesa de potencia: sirve para comprobar que la evolucion hace algo.
func _medir(arma: Arma) -> int:
	var total := 0
	for metodo in ["dano", "cantidad", "proyectiles", "radio", "alcance", "duracion"]:
		if arma.has_method(metodo):
			total += int(arma.call(metodo))
	return total


func _probar_cupos() -> void:
	var j := await _nuevo_jugador()
	for id in Data.ARMAS:
		if j.hay_cupo_de_arma():
			j.agregar_arma(id)
	await get_tree().process_frame
	_revisar(j.armas.size() == Data.MAX_ARMAS,
		"el jugador no pasa de %d armas (tiene %d)" % [Data.MAX_ARMAS, j.armas.size()])

	for id in Data.PASIVAS:
		if j.hay_cupo_de_pasiva():
			j.subir_pasiva(id)
	_revisar(j.pasivas.size() == Data.MAX_PASIVAS,
		"el jugador no pasa de %d pasivas (tiene %d)" % [Data.MAX_PASIVAS, j.pasivas.size()])
	j.free()
