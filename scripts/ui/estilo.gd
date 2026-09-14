class_name Estilo
extends RefCounted

# Helpers de interfaz compartidos por los menus, para que todos se vean igual
# sin repetir el mismo codigo de estilo tres veces.

const CREMA := Color(0.96, 0.92, 0.84)
const ROJO := Color(0.78, 0.24, 0.26)
const DORADO := Color(0.98, 0.82, 0.38)
const OSCURO := Color(0.13, 0.10, 0.12)


static func label(texto: String, tamano: int, color := CREMA) -> Label:
	var l := Label.new()
	l.text = texto
	l.add_theme_font_size_override("font_size", tamano)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.75))
	l.add_theme_constant_override("shadow_offset_y", 2)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l


static func caja(relleno: Color, borde: Color, radio := 6, margen_v := 10) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = relleno
	s.border_color = borde
	s.set_border_width_all(2)
	s.set_corner_radius_all(radio)
	s.content_margin_left = 18
	s.content_margin_right = 18
	s.content_margin_top = margen_v
	s.content_margin_bottom = margen_v
	return s


static func boton(texto: String, ancho := 300.0) -> Button:
	var b := Button.new()
	b.text = texto
	b.custom_minimum_size = Vector2(ancho, 52)
	b.add_theme_font_size_override("font_size", 21)
	b.add_theme_color_override("font_color", CREMA)
	b.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	b.add_theme_color_override("font_focus_color", Color(1, 1, 1))
	b.add_theme_stylebox_override("normal", caja(Color(0.20, 0.15, 0.17), Color(0.42, 0.32, 0.30)))
	b.add_theme_stylebox_override("hover", caja(Color(0.30, 0.19, 0.20), DORADO))
	b.add_theme_stylebox_override("focus", caja(Color(0.30, 0.19, 0.20), DORADO))
	b.add_theme_stylebox_override("pressed", caja(Color(0.38, 0.22, 0.22), DORADO))
	b.add_theme_stylebox_override("disabled", caja(Color(0.16, 0.14, 0.15), Color(0.26, 0.23, 0.24)))
	b.add_theme_color_override("font_disabled_color", Color(0.55, 0.51, 0.50))
	return b


static func fondo_oscuro(alfa := 0.72) -> ColorRect:
	var r := ColorRect.new()
	r.color = Color(0, 0, 0, alfa)
	r.set_anchors_preset(Control.PRESET_FULL_RECT)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r


static func columna_centrada(separacion := 16) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.set_anchors_preset(Control.PRESET_CENTER)
	v.grow_horizontal = Control.GROW_DIRECTION_BOTH
	v.grow_vertical = Control.GROW_DIRECTION_BOTH
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", separacion)
	return v
