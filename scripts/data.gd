class_name Data
extends RefCounted

# Todo el contenido del juego vive aca. Para balancear el juego solo tocas
# este archivo: no hay que entrar a la logica.

const DURACION_BIOMA := 120.0

const BIOMAS := [
	{
		"nombre": "La Fonda",
		"fondo": Color(0.20, 0.13, 0.10),
		"suelo": Color(0.28, 0.19, 0.13),
		"enemigos": ["quiltro", "borracho", "gaviota"],
	},
	{
		"nombre": "Desierto de Atacama",
		"fondo": Color(0.38, 0.27, 0.14),
		"suelo": Color(0.55, 0.41, 0.23),
		"enemigos": ["momia", "ovni", "quiltro"],
	},
	{
		"nombre": "Valparaiso",
		"fondo": Color(0.12, 0.15, 0.22),
		"suelo": Color(0.18, 0.22, 0.31),
		"enemigos": ["gaviota", "colo_colo", "quiltro"],
	},
	{
		"nombre": "Chiloe",
		"fondo": Color(0.06, 0.11, 0.12),
		"suelo": Color(0.11, 0.19, 0.19),
		"enemigos": ["trauco", "invunche", "gaviota"],
	},
	{
		"nombre": "Isla de Pascua",
		"fondo": Color(0.16, 0.23, 0.13),
		"suelo": Color(0.27, 0.37, 0.20),
		"enemigos": ["aku_aku", "moai", "colo_colo"],
	},
]

# vida/dano/velocidad son los valores base: el juego los escala con el tiempo.
const ENEMIGOS := {
	"quiltro": {
		"nombre": "Quiltro rabioso",
		"vida": 10, "velocidad": 168.0, "dano": 6, "radio": 10.0, "xp": 1,
		"color": Color(0.55, 0.40, 0.28),
	},
	"borracho": {
		"nombre": "Tio curado",
		"vida": 26, "velocidad": 62.0, "dano": 11, "radio": 15.0, "xp": 2,
		"color": Color(0.72, 0.35, 0.42),
	},
	"momia": {
		"nombre": "Momia chinchorro",
		"vida": 34, "velocidad": 72.0, "dano": 10, "radio": 14.0, "xp": 2,
		"color": Color(0.78, 0.70, 0.50),
	},
	"ovni": {
		"nombre": "OVNI del norte",
		"vida": 16, "velocidad": 236.0, "dano": 8, "radio": 12.0, "xp": 3,
		"color": Color(0.45, 0.85, 0.70),
	},
	"gaviota": {
		"nombre": "Gaviota porteña",
		"vida": 14, "velocidad": 248.0, "dano": 7, "radio": 10.0, "xp": 2,
		"color": Color(0.88, 0.88, 0.92),
	},
	"colo_colo": {
		"nombre": "Colo Colo",
		"vida": 30, "velocidad": 110.0, "dano": 12, "radio": 13.0, "xp": 3,
		"color": Color(0.85, 0.55, 0.20),
	},
	"trauco": {
		"nombre": "Trauco",
		"vida": 44, "velocidad": 95.0, "dano": 15, "radio": 16.0, "xp": 4,
		"color": Color(0.40, 0.62, 0.35),
	},
	"invunche": {
		"nombre": "Invunche",
		"vida": 120, "velocidad": 54.0, "dano": 22, "radio": 24.0, "xp": 12,
		"color": Color(0.60, 0.25, 0.30),
	},
	"aku_aku": {
		"nombre": "Aku-aku",
		"vida": 22, "velocidad": 262.0, "dano": 10, "radio": 11.0, "xp": 3,
		"color": Color(0.70, 0.62, 0.95),
	},
	"moai": {
		"nombre": "Moai caminante",
		"vida": 220, "velocidad": 46.0, "dano": 28, "radio": 30.0, "xp": 20,
		"color": Color(0.52, 0.52, 0.50),
	},
}

# Mejoras permanentes que se compran en la fonda entre partidas.
# El costo de cada nivel es costo_base * (nivel_actual + 1).
const PERMANENTES := [
	{
		"id": "vida_campo", "nombre": "Vida de campo",
		"desc": "+15 vida maxima", "max": 5, "costo_base": 120,
		"color": Color(0.88, 0.32, 0.36),
	},
	{
		"id": "buena_mano", "nombre": "Buena mano",
		"desc": "+8% daño", "max": 5, "costo_base": 150,
		"color": Color(0.92, 0.58, 0.25),
	},
	{
		"id": "piernas", "nombre": "Piernas de huaso",
		"desc": "+5% velocidad", "max": 3, "costo_base": 140,
		"color": Color(0.55, 0.88, 0.58),
	},
	{
		"id": "bolsillo", "nombre": "Bolsillo grande",
		"desc": "+25 radio de recogida", "max": 3, "costo_base": 100,
		"color": Color(0.62, 0.66, 0.95),
	},
	{
		"id": "once", "nombre": "La once",
		"desc": "+0.25 vida regenerada por segundo", "max": 4, "costo_base": 180,
		"color": Color(0.86, 0.62, 0.36),
	},
	{
		"id": "buen_ojo", "nombre": "Buen ojo",
		"desc": "+8% velocidad de ataque", "max": 4, "costo_base": 170,
		"color": Color(0.60, 0.86, 0.95),
	},
]


# Un jefe por bioma. "figura" dice que silueta usar de dibujos.gd.
const JEFES := [
	{
		"nombre": "Don Fondita", "figura": "borracho",
		"vida": 900, "velocidad": 78.0, "dano": 26, "radio": 46.0,
		"xp": 45, "lucas": 60, "color": Color(0.82, 0.30, 0.38),
	},
	{
		"nombre": "Momia Ancestral", "figura": "momia",
		"vida": 1500, "velocidad": 88.0, "dano": 30, "radio": 48.0,
		"xp": 60, "lucas": 90, "color": Color(0.86, 0.78, 0.55),
	},
	{
		"nombre": "Colo Colo Mayor", "figura": "colo_colo",
		"vida": 2300, "velocidad": 122.0, "dano": 34, "radio": 46.0,
		"xp": 80, "lucas": 130, "color": Color(0.92, 0.52, 0.16),
	},
	{
		"nombre": "El Invunche", "figura": "invunche",
		"vida": 3400, "velocidad": 96.0, "dano": 40, "radio": 52.0,
		"xp": 105, "lucas": 180, "color": Color(0.66, 0.24, 0.30),
	},
	{
		"nombre": "Moai Ancestral", "figura": "moai",
		"vida": 5200, "velocidad": 74.0, "dano": 48, "radio": 60.0,
		"xp": 150, "lucas": 260, "color": Color(0.58, 0.58, 0.55),
	},
]

# --- Logros -----------------------------------------------------------------
# "campo" es el contador de Guardado que se compara contra "meta". Al cumplirse
# se paga el premio en lucas una sola vez.
const LOGROS := [
	{
		"id": "cien", "nombre": "Buen comienzo",
		"desc": "Mata 100 enemigos en total",
		"campo": "muertes", "meta": 100, "premio": 80,
	},
	{
		"id": "mil", "nombre": "Carnicero de fonda",
		"desc": "Mata 1000 enemigos en total",
		"campo": "muertes", "meta": 1000, "premio": 250,
	},
	{
		"id": "diez_mil", "nombre": "Plaga nacional",
		"desc": "Mata 10000 enemigos en total",
		"campo": "muertes", "meta": 10000, "premio": 800,
	},
	{
		"id": "aguante_3", "nombre": "Aguanta el carrete",
		"desc": "Sobrevive 3 minutos en una partida",
		"campo": "mejor_tiempo", "meta": 180, "premio": 120,
	},
	{
		"id": "aguante_8", "nombre": "Llegaste a Chiloe",
		"desc": "Sobrevive 8 minutos en una partida",
		"campo": "mejor_tiempo", "meta": 480, "premio": 350,
	},
	{
		"id": "jefe_1", "nombre": "Se cayo el tio",
		"desc": "Derrota tu primer jefe",
		"campo": "jefes_derrotados", "meta": 1, "premio": 150,
	},
	{
		"id": "jefe_5", "nombre": "Cazador de mitos",
		"desc": "Derrota 5 jefes en total",
		"campo": "jefes_derrotados", "meta": 5, "premio": 400,
	},
	{
		"id": "nivel_20", "nombre": "Veinte de nivel",
		"desc": "Llega a nivel 20 en una partida",
		"campo": "mejor_nivel", "meta": 20, "premio": 200,
	},
	{
		"id": "evo_1", "nombre": "Se puso buena la cosa",
		"desc": "Evoluciona un arma",
		"campo": "evoluciones", "meta": 1, "premio": 250,
	},
	{
		"id": "evo_5", "nombre": "Maestro fondero",
		"desc": "Evoluciona 5 armas en total",
		"campo": "evoluciones", "meta": 5, "premio": 600,
	},
	{
		"id": "insistente", "nombre": "Una mas y me voy",
		"desc": "Juega 10 partidas",
		"campo": "partidas", "meta": 10, "premio": 150,
	},
]


# --- Personajes -------------------------------------------------------------
# Los multiplicadores se aplican sobre las estadisticas base del jugador.
# "costo" en lucas; 0 es el que viene desbloqueado de entrada.
const PERSONAJES := [
	{
		"id": "huaso", "nombre": "El Huaso",
		"desc": "Equilibrado. El de siempre.",
		"arma": "anticucho", "costo": 0,
		"vida": 1.0, "velocidad": 1.0, "dano": 1.0, "vel_ataque": 1.0,
		"color": Color(0.78, 0.24, 0.26),
	},
	{
		"id": "minero", "nombre": "El Minero",
		"desc": "Pega mucho mas fuerte, pero aguanta menos y es lento.",
		"arma": "chuzo", "costo": 400,
		"vida": 0.85, "velocidad": 0.92, "dano": 1.30, "vel_ataque": 1.0,
		"color": Color(0.92, 0.70, 0.16),
	},
	{
		"id": "pescadora", "nombre": "La Pescadora",
		"desc": "Mucha vida y regeneracion, pero mas lenta.",
		"arma": "cacerola", "costo": 600,
		"vida": 1.45, "velocidad": 0.90, "dano": 0.95, "vel_ataque": 1.0,
		"regen": 0.5,
		"color": Color(0.90, 0.62, 0.18),
	},
	{
		"id": "micrero", "nombre": "El Micrero",
		"desc": "Rapido y ataca seguido, pero es de vidrio.",
		"arma": "micro", "costo": 900,
		"vida": 0.82, "velocidad": 1.18, "dano": 1.0, "vel_ataque": 1.25,
		"color": Color(0.42, 0.62, 0.82),
	},
]


# --- Armas ------------------------------------------------------------------
# El jugador puede llevar hasta MAX_ARMAS a la vez, asi que cada partida obliga
# a elegir un camino distinto.
const MAX_ARMAS := 4

const ARMAS := {
	"anticucho": {
		"nombre": "Anticucho flamigero",
		"desc": "Dispara solo al enemigo mas cercano",
		"script": "res://scripts/weapons/anticucho.gd",
		"color": Color(1.0, 0.55, 0.15),
	},
	"cacerola": {
		"nombre": "Cacerola",
		"desc": "Cacerolazo que golpea todo alrededor",
		"script": "res://scripts/weapons/cacerola.gd",
		"color": Color(0.80, 0.80, 0.85),
	},
	"volantin": {
		"nombre": "Volantin con hilo curado",
		"desc": "Volantines que orbitan y cortan",
		"script": "res://scripts/weapons/volantin.gd",
		"color": Color(0.95, 0.55, 0.75),
	},
	"chuzo": {
		"nombre": "Chuzo minero",
		"desc": "Golpe de arco hacia donde miras. Pega fuerte, pero de cerca",
		"script": "res://scripts/weapons/chuzo.gd",
		"color": Color(0.70, 0.70, 0.74),
	},
	"terremoto": {
		"nombre": "Copa de terremoto",
		"desc": "Deja charcos que van dañando",
		"script": "res://scripts/weapons/terremoto.gd",
		"color": Color(0.95, 0.82, 0.40),
	},
	"quiltro_fiel": {
		"nombre": "Quiltro fiel",
		"desc": "Un perro que sale solo a morder",
		"script": "res://scripts/weapons/quiltro_fiel.gd",
		"color": Color(0.75, 0.62, 0.45),
	},
	"micro": {
		"nombre": "Micro amarilla",
		"desc": "Cruza la pantalla atropellando todo",
		"script": "res://scripts/weapons/micro.gd",
		"color": Color(0.95, 0.78, 0.18),
	},
}


# --- Pasivas ----------------------------------------------------------------
# Suben estadisticas. Una pasiva al maximo habilita la evolucion de su arma.
const MAX_PASIVAS := 4

const PASIVAS := {
	"piscola": {
		"nombre": "Piscola", "desc": "+15% velocidad de movimiento",
		"max": 4, "color": Color(0.95, 0.80, 0.35),
	},
	"pebre": {
		"nombre": "Pebre picante", "desc": "+20% daño",
		"max": 4, "color": Color(0.90, 0.35, 0.30),
	},
	"empanada": {
		"nombre": "Empanada de pino", "desc": "+20 vida maxima y cura 30",
		"max": 4, "color": Color(0.90, 0.70, 0.40),
	},
	"mote": {
		"nombre": "Mote con huesillo", "desc": "+0.6 vida por segundo",
		"max": 4, "color": Color(0.85, 0.60, 0.35),
	},
	"hilo_curado": {
		"nombre": "Hilo curado", "desc": "+20% velocidad de ataque",
		"max": 4, "color": Color(0.60, 0.85, 0.95),
	},
	"iman": {
		"nombre": "Iman de feria", "desc": "+50 radio de recogida",
		"max": 4, "color": Color(0.65, 0.65, 0.95),
	},
	"zapatillas": {
		"nombre": "Zapatillas de fonda", "desc": "+12% velocidad y +10 vida",
		"max": 4, "color": Color(0.55, 0.90, 0.60),
	},
}


# --- Evoluciones ------------------------------------------------------------
# Arma al maximo + su pasiva al maximo = version evolucionada. Es la
# recompensa por comprometerse con un camino en vez de tomar de todo un poco.
const EVOLUCIONES := [
	{
		"arma": "anticucho", "pasiva": "pebre",
		"nombre": "Parrillada completa",
		"desc": "El anticucho dispara en todas las direcciones",
		"color": Color(1.0, 0.42, 0.12),
	},
	{
		"arma": "cacerola", "pasiva": "piscola",
		"nombre": "Cacerolazo nacional",
		"desc": "Radio enorme y empuja a los enemigos",
		"color": Color(0.98, 0.84, 0.36),
	},
	{
		"arma": "volantin", "pasiva": "hilo_curado",
		"nombre": "Comision de volantines",
		"desc": "Diez volantines, mas lejos y mas rapidos",
		"color": Color(0.98, 0.78, 0.32),
	},
	{
		"arma": "chuzo", "pasiva": "zapatillas",
		"nombre": "Chuzo del minero",
		"desc": "El arco se cierra en 360 grados",
		"color": Color(0.98, 0.72, 0.30),
	},
	{
		"arma": "terremoto", "pasiva": "mote",
		"nombre": "Maremoto",
		"desc": "Charcos enormes que duran mucho mas",
		"color": Color(0.55, 0.80, 0.95),
	},
	{
		"arma": "quiltro_fiel", "pasiva": "empanada",
		"nombre": "La jauria",
		"desc": "Tres quiltros en vez de uno",
		"color": Color(0.92, 0.86, 0.72),
	},
	{
		"arma": "micro", "pasiva": "iman",
		"nombre": "Transantiago",
		"desc": "Tres micros cruzando a la vez",
		"color": Color(0.35, 0.66, 0.92),
	},
]
