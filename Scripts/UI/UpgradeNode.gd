extends PanelContainer

signal achete(id)

var _id: String
var _categorie: String
var _icone: String = "?"
var _nom: String = ""
var _desc: String = ""
var _prix_base: int = 10
var _niv_max: int = 5
var _prix_double: bool = false
var _is_prestige: bool = false

var _tooltip: Panel
var _anim_scale: float = 1.0

func setup(id: String, cat: String, icone: String, nom: String, desc: String,
		   prix: int, niv_max: int, doubl: bool = false, prestige: bool = false):
	_id = id; _categorie = cat; _icone = icone; _nom = nom; _desc = desc
	_prix_base = prix; _niv_max = niv_max; _prix_double = doubl; _is_prestige = prestige
	
	custom_minimum_size = Vector2(80, 80)
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	var cbs = StyleBoxFlat.new()
	cbs.bg_color = Color(0.15, 0.12, 0.08)
	cbs.corner_radius_top_left = 8; cbs.corner_radius_top_right = 8
	cbs.corner_radius_bottom_left = 8; cbs.corner_radius_bottom_right = 8
	cbs.border_width_left = 2; cbs.border_width_top = 2
	cbs.border_width_right = 2; cbs.border_width_bottom = 2
	cbs.border_color = Color(0.6, 0.5, 0.2, 0.5)
	cbs.content_margin_left = 6; cbs.content_margin_top = 6
	cbs.content_margin_right = 6; cbs.content_margin_bottom = 6
	add_theme_stylebox_override("panel", cbs)
	
	var lbl = Label.new()
	lbl.text = icone
	lbl.add_theme_font_size_override("font_size", 28)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(lbl)
	
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_unhover)
	gui_input.connect(_on_click)

func _get_niveau() -> int:
	if _is_prestige:
		return GameManager.shop_niveaux.get(_id, 0)
	match _id:
		"clic": return GameManager.niveau_clic
		"vitesse_click": return GameManager.niveau_vitesse_click
		"max": return GameManager.ouvrieres
		"vitesse_ouvriere": return GameManager.niveau_vitesse_ouvriere
		"capacite_ouvriere": return GameManager.niveau_capacite_ouvriere
		"guerriere": return GameManager.niveau_guerriere
		"max_butineuse": return GameManager.niveau_max_butineuse
	return 0

func _get_max() -> int:
	match _id:
		"max": return GameManager.get_max_ouvrieres()
		"guerriere": return GameManager.get_guerriere_max()
		"max_butineuse": return 99
	return _niv_max

func _get_prix() -> int:
	if _is_prestige:
		var base = _prix_base
		var niv = GameManager.shop_niveaux.get(_id, 0)
		if _prix_double: return base * int(pow(2, niv))
		return base
	match _id:
		"clic": return GameManager.get_cout_clic()
		"vitesse_click": return GameManager.get_cout_vitesse_click()
		"max": return GameManager.COUT_OUVRIERE
		"vitesse_ouvriere": return GameManager.get_cout_vitesse_ouvriere()
		"capacite_ouvriere": return GameManager.get_cout_capacite_ouvriere()
		"guerriere": return GameManager.get_guerriere_cout()
		"max_butineuse": return GameManager.get_cout_max_butineuse()
	return 99999

func _peut_acheter() -> bool:
	var niv = _get_niveau()
	if _is_prestige and niv >= GameManager.shop_niveaux.get(_id, 0): niv = _get_niveau()
	if niv >= _get_max(): return false
	if _is_prestige: return GameManager.pollen >= _get_prix()
	return GameManager.honey >= _get_prix()

func _est_max() -> bool:
	return _get_niveau() >= _get_max()

func _on_hover():
	_show_tooltip()
	var t = create_tween()
	t.tween_property(self, "_anim_scale", 1.1, 0.15)
	t.parallel().tween_property(self, "rotation", deg_to_rad(randf_range(-2, 2)), 0.15)

func _on_unhover():
	_hide_tooltip()
	var t = create_tween()
	t.tween_property(self, "_anim_scale", 1.0, 0.15)
	t.parallel().tween_property(self, "rotation", 0.0, 0.15)

func _on_click(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _peut_acheter() and _acheter():
			achete.emit(_id)

func _acheter() -> bool:
	var succes = false
	if _is_prestige:
		succes = GameManager.acheter_shop(_id)
	else:
		match _id:
			"clic": succes = GameManager.acheter_clic()
			"vitesse_click": succes = GameManager.acheter_vitesse_click()
			"max": succes = GameManager.acheter_ouvriere()
			"vitesse_ouvriere": succes = GameManager.acheter_vitesse_ouvriere()
			"capacite_ouvriere": succes = GameManager.acheter_capacite_ouvriere()
			"guerriere": succes = GameManager.acheter_guerriere()
			"max_butineuse": succes = GameManager.acheter_max_butineuse()
	if not succes: return false
	_flash_achat()
	return true

func _flash_achat():
	var t = create_tween()
	t.tween_property(self, "modulate", Color(2, 2, 1, 1), 0.05)
	t.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.15)

func _show_tooltip():
	_tooltip = Panel.new()
	_tooltip.name = "Tooltip"
	var tbs = StyleBoxFlat.new(); tbs.bg_color = Color(0.1, 0.08, 0.05, 0.95)
	tbs.corner_radius_top_left = 6; tbs.corner_radius_top_right = 6
	tbs.corner_radius_bottom_left = 6; tbs.corner_radius_bottom_right = 6
	tbs.border_width_left = 1; tbs.border_width_top = 1
	tbs.border_width_right = 1; tbs.border_width_bottom = 1
	tbs.border_color = Color(0.6, 0.5, 0.2, 0.8)
	tbs.content_margin_left = 10; tbs.content_margin_top = 6; tbs.content_margin_right = 10; tbs.content_margin_bottom = 6
	_tooltip.add_theme_stylebox_override("panel", tbs)
	_tooltip.position = get_global_mouse_position() + Vector2(20, -40)
	var tb = VBoxContainer.new(); _tooltip.add_child(tb)
	var nl = Label.new(); nl.text = _nom + " (niv " + str(_get_niveau()) + "/" + str(_get_max()) + ")"
	nl.add_theme_font_size_override("font_size", 12); nl.add_theme_color_override("font_color", Color(1, 1, 1))
	tb.add_child(nl)
	var dl = Label.new(); dl.text = _desc
	dl.add_theme_font_size_override("font_size", 10); dl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	tb.add_child(dl)
	var pl = Label.new()
	if _est_max():
		pl.text = "MAX"; pl.add_theme_color_override("font_color", Color(1, 0.5, 0.2))
	else:
		pl.text = "Cout: " + _currency() + str(_get_prix()) + " | " + ("Pollen" if _is_prestige else "Miel")
		pl.add_theme_color_override("font_color", Color(0.4, 1, 0.4) if _peut_acheter() else Color(1, 0.3, 0.3))
	pl.add_theme_font_size_override("font_size", 10)
	tb.add_child(pl)
	add_child(_tooltip)

func _currency():
	return "P" if _is_prestige else "M"

func _hide_tooltip():
	if _tooltip: _tooltip.queue_free()
