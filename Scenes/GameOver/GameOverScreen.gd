extends Panel

signal ferme

const ARTICLES = preload("res://Scripts/prestige_items.gd").ARTICLES
var _pollen_label: Label
var _card_container: VBoxContainer

func _init():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _ready():
	_resize_to_viewport()
	if not get_viewport().size_changed.is_connected(_resize_to_viewport):
		get_viewport().size_changed.connect(_resize_to_viewport)
	
	var bg = TextureRect.new()
	bg.anchor_right = 1.0; bg.anchor_bottom = 1.0; bg.stretch_mode = 0
	var bg_tex = load("res://Assets/Sprites/UI/bg_gameover.png")
	if bg_tex: bg.texture = bg_tex
	add_child(bg)
	
	var overlay = Panel.new()
	overlay.anchor_right = 1.0; overlay.anchor_bottom = 1.0
	var obs = StyleBoxFlat.new(); obs.bg_color = Color(0, 0, 0, 0.65)
	overlay.add_theme_stylebox_override("panel", obs)
	add_child(overlay)
	
	var vb = VBoxContainer.new(); vb.anchor_right = 1.0; vb.anchor_bottom = 1.0
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(vb)
	
	# Icone Game Over centree
	var go_icon = TextureRect.new()
	var git = load("res://Assets/Sprites/UI/gameover_icon.png")
	if git: go_icon.texture = git; go_icon.stretch_mode = 0
	go_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	go_icon.custom_minimum_size = Vector2(0, 170)
	go_icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	go_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	vb.add_child(go_icon)
	
	# Stats
	var tot = GameManager.honey_this_run
	var dols = int(tot / 1000)
	var stats = Label.new()
	stats.text = "Miel: " + str(tot) + "\\nPollen: +" + str(dols)
	stats.add_theme_font_size_override("font_size", 14)
	stats.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(stats)
	
	# Dollars
	_pollen_label = Label.new()
	_pollen_label.text = "\U0001f4b5 " + str(GameManager.pollen)
	_pollen_label.add_theme_font_size_override("font_size", 22)
	_pollen_label.add_theme_color_override("font_color", Color(0.4, 1, 0.4))
	_pollen_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(_pollen_label)
	
	# Scroll avec upgrades
	var sc = ScrollContainer.new()
	sc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sc.custom_minimum_size = Vector2(0, 180)
	vb.add_child(sc)
	
	_card_container = VBoxContainer.new()
	_card_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_card_container.add_theme_constant_override("separation", 6)
	sc.add_child(_card_container)
	
	_refresh_cards()
	
	# Boutons du bas
	var btn_box = HBoxContainer.new()
	btn_box.alignment = 1
	btn_box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vb.add_child(btn_box)
	
	var restart_btn = Button.new()
	restart_btn.text = "\U0001f504 Recommencer"
	restart_btn.custom_minimum_size = Vector2(220, 45)
	restart_btn.add_theme_font_size_override("font_size", 16)
	restart_btn.pressed.connect(_on_restart_click)
	btn_box.add_child(restart_btn)

func _refresh_cards():
	for c in _card_container.get_children(): c.queue_free()
	for a in ARTICLES:
		var niv = GameManager.shop_niveaux.get(a.id, 0)
		var fini = niv >= a.max
		var prix = a.prix if not a.get("double", false) else a.prix * int(pow(2, niv))
		var peut = GameManager.pollen >= prix and not fini
		
		var card = PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.custom_minimum_size = Vector2(0, 56)
		var cbs = StyleBoxFlat.new(); cbs.bg_color = Color(0.12, 0.12, 0.2)
		cbs.corner_radius_top_left = 6; cbs.corner_radius_top_right = 6
		cbs.corner_radius_bottom_left = 6; cbs.corner_radius_bottom_right = 6
		cbs.content_margin_left = 10; cbs.content_margin_top = 6; cbs.content_margin_bottom = 6
		card.add_theme_stylebox_override("panel", cbs)
		_card_container.add_child(card)
		
		var h = HBoxContainer.new()
		h.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.size_flags_vertical = Control.SIZE_EXPAND_FILL
		card.add_child(h)
		
		var v = VBoxContainer.new(); v.size_flags_horizontal = 3; h.add_child(v)
		
		var l1 = Label.new()
		l1.text = a.nom + " (" + str(niv) + "/" + str(a.max) + ")"
		l1.add_theme_font_size_override("font_size", 14)
		if fini: l1.add_theme_color_override("font_color", Color(0.3, 0.9, 0.3))
		elif peut: l1.add_theme_color_override("font_color", Color(1, 0.9, 0.2))
		else: l1.add_theme_color_override("font_color", Color(0.8, 0.4, 0.4))
		v.add_child(l1)
		
		var l2 = Label.new(); l2.text = a.desc
		l2.add_theme_font_size_override("font_size", 11)
		l2.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		v.add_child(l2)
		
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(80, 30)
		if fini: btn.text = "MAX"; btn.disabled = true
		elif peut: btn.text = "\U0001f4b5" + str(prix)
		else: btn.text = "\U0001f4b5" + str(prix); btn.disabled = true
		if peut: btn.pressed.connect(_acheter.bind(a.id))
		h.add_child(btn)

func _refresh_shop():
	_pollen_label.text = "\U0001f4b5 " + str(GameManager.pollen)
	_refresh_cards()

func _acheter(article_id):
	if GameManager.acheter_shop(article_id):
		_refresh_shop()

func _on_restart_click():
	if has_node("ConfirmPanel"): return
	var confirm = Panel.new()
	confirm.name = "ConfirmPanel"
	confirm.anchor_right = 1.0; confirm.anchor_bottom = 1.0
	var cbg = StyleBoxFlat.new(); cbg.bg_color = Color(0, 0, 0, 0.8)
	confirm.add_theme_stylebox_override("panel", cbg)
	confirm.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(confirm)
	
	var cc = CenterContainer.new()
	cc.anchor_right = 1.0; cc.anchor_bottom = 1.0
	confirm.add_child(cc)
	
	var cvb = VBoxContainer.new()
	cvb.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	cvb.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	cc.add_child(cvb)
	
	var ct = Label.new()
	ct.text = "Tout recommencer ?\nLe pollen est conserve\u00e9s."
	ct.add_theme_font_size_override("font_size", 20)
	ct.add_theme_color_override("font_color", Color(1, 1, 1))
	ct.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cvb.add_child(ct)
	
	var btn_h = HBoxContainer.new()
	btn_h.alignment = 1
	btn_h.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn_h.add_theme_constant_override("separation", 20)
	cvb.add_child(btn_h)
	
	var yb = Button.new()
	yb.text = "Oui"
	yb.custom_minimum_size = Vector2(100, 40)
	yb.pressed.connect(_confirm_restart_action)
	btn_h.add_child(yb)
	
	var nb = Button.new()
	nb.text = "Non"
	nb.custom_minimum_size = Vector2(100, 40)
	nb.pressed.connect(confirm.queue_free)
	btn_h.add_child(nb)


func _confirm_restart_action():
	ferme.emit()
	queue_free()

func _resize_to_viewport():
	position = Vector2.ZERO
	size = get_viewport_rect().size
