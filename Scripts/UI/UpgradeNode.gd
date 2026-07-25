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
	if _is_prestige: return GameManager.dollars >= _get_prix()
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
		if _peut_acheter():
			_acheter()
			achete.emit(_id)

func _acheter():
	var prix = _get_prix()
	if _is_prestige:
		if GameManager.dollars < prix: return
		GameManager.dollars -= prix
		GameManager.shop_niveaux[_id] = GameManager.shop_niveaux.get(_id, 0) + 1
		GameManager.save()
	else:
		if GameManager.honey < prix: return
		GameManager.honey -= prix
		match _id:
			"clic": GameManager.niveau_clic += 1
			"vitesse_click": GameManager.niveau_vitesse_click += 1
			"max": GameManager.acheter_ouvriere()
			"vitesse_ouvriere": GameManager.niveau_vitesse_ouvriere += 1
			"capacite_ouvriere": GameManager.niveau_capacite_ouvriere += 1
			"guerriere": GameManager.niveau_guerriere += 1
			"max_butineuse": GameManager.niveau_max_butineuse += 1
		GameManager.save()
		GameManager.honey_change.emit(GameManager.honey)
	
	# Flash
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
	
	var nom_l = Label.new()
	var niv = _get_niveau()
	var max_str = "MAX" if _est_max() else str(niv) + " / " + str(_get_max())
	nom_l.text = _nom + " (" + max_str + ")"
	nom_l.add_theme_font_size_override("font_size", 14)
	var col = Color(0.6, 0.5, 0.2) if _est_max() else Color(1, 0.9, 0.3) if _peut_acheter() else Color(0.8, 0.4, 0.4)
	nom_l.add_theme_color_override("font_color", col)
	tb.add_child(nom_l)
	
	var desc_l = Label.new(); desc_l.text = _desc
	desc_l.add_theme_font_size_override("font_size", 11)
	desc_l.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	desc_l.autowrap_mode = TextServer.AUTOWRAP_WORD
	tb.add_child(desc_l)
	
	if not _est_max():
		var p_l = Label.new()
		var currency = "💵" if _is_prestige else "🍯"
		p_l.text = "Coût : " + currency + str(_get_prix())
		p_l.add_theme_font_size_override("font_size", 12)
		p_l.add_theme_color_override("font_color", Color(0.3, 1, 0.3) if _peut_acheter() else Color(0.8, 0.4, 0.4))
		tb.add_child(p_l)
	
	add_child(_tooltip)

func _hide_tooltip():
	var t = get_node_or_null("Tooltip")
	if t: t.queue_free()

func _process(_delta):
	scale = Vector2(_anim_scale, _anim_scale)
	# Mise a jour visuelle
	var peut = _peut_acheter()
	var est_max = _est_max()
	var cbs = get_theme_stylebox("panel") as StyleBoxFlat
	if cbs:
		if est_max: cbs.border_color = Color(0.3, 0.9, 0.3, 0.8)
		elif peut: cbs.border_color = Color(1, 0.9, 0.2, 0.8)
		else: cbs.border_color = Color(0.6, 0.5, 0.2, 0.3)
		modulate = Color(1, 1, 1, 1) if peut or est_max else Color(0.5, 0.5, 0.5, 0.6)
