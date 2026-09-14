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

# Cada mejora se aplica en player.gd -> aplicar_mejora().
# "arma" significa que desbloquea o sube de nivel un arma.
const MEJORAS := [
	{
		"id": "piscola",
		"nombre": "Piscola",
		"desc": "+15% velocidad de movimiento",
		"color": Color(0.95, 0.80, 0.35),
	},
	{
		"id": "pebre",
		"nombre": "Pebre picante",
		"desc": "+20% daño",
		"color": Color(0.90, 0.35, 0.30),
	},
	{
		"id": "empanada",
		"nombre": "Empanada de pino",
		"desc": "+20 vida maxima y cura 30",
		"color": Color(0.90, 0.70, 0.40),
	},
	{
		"id": "mote",
		"nombre": "Mote con huesillo",
		"desc": "+0.6 vida regenerada por segundo",
		"color": Color(0.85, 0.60, 0.35),
	},
	{
		"id": "hilo_curado",
		"nombre": "Hilo curado",
		"desc": "+20% velocidad de ataque",
		"color": Color(0.60, 0.85, 0.95),
	},
	{
		"id": "iman",
		"nombre": "Iman de feria",
		"desc": "+50 radio de recogida de XP",
		"color": Color(0.65, 0.65, 0.95),
	},
	{
		"id": "zapatillas",
		"nombre": "Zapatillas de fonda",
		"desc": "+12% velocidad y +10 vida maxima",
		"color": Color(0.55, 0.90, 0.60),
	},
	{
		"id": "anticucho",
		"nombre": "Anticucho flamigero",
		"desc": "Dispara mas rapido y mas proyectiles",
		"arma": true,
		"color": Color(1.0, 0.55, 0.15),
	},
	{
		"id": "cacerola",
		"nombre": "Cacerola",
		"desc": "Cacerolazo: mas daño y alcance",
		"arma": true,
		"color": Color(0.80, 0.80, 0.85),
	},
	{
		"id": "volantin",
		"nombre": "Volantin con hilo curado",
		"desc": "Volantines que orbitan y cortan",
		"arma": true,
		"color": Color(0.95, 0.55, 0.75),
	},
]
