extends Panel

signal ferme

const PESTICIDES = [
	{"id": "imidaclopride", "nom": "Imidaclopride", "type": "Néonicotinoïde", "danger": 5, "desc": "Neurotoxique, perturbe l'orientation des abeilles.", "deputes": 8},
	{"id": "clothianidine", "nom": "Clothianidine", "type": "Néonicotinoïde", "danger": 5, "desc": "Tue les abeilles à très faible dose.", "deputes": 8},
	{"id": "thiamethoxame", "nom": "Thiaméthoxame", "type": "Néonicotinoïde", "danger": 5, "desc": "Contamine le pollen et le nectar des fleurs.", "deputes": 7},
	{"id": "acetamipride", "nom": "Acétamipride", "type": "Néonicotinoïde", "danger": 4, "desc": "Seul néonicotinoïde encore autorisé en France.", "deputes": 6},
	{"id": "fipronil", "nom": "Fipronil", "type": "Phénylpyrazole", "danger": 5, "desc": "Une seule goutte peut tuer une ruche entière.", "deputes": 9},
	{"id": "chlorpyriphos", "nom": "Chlorpyriphos", "type": "Organophosphoré", "danger": 4, "desc": "Inhibe le système nerveux des insectes.", "deputes": 6},
	{"id": "cypermethrine", "nom": "Cyperméthrine", "type": "Pyréthrinoïde", "danger": 3, "desc": "Répulsif mais toxique à forte dose.", "deputes": 4},
	{"id": "deltamethrine", "nom": "Deltaméthrine", "type": "Pyréthrinoïde", "danger": 3, "desc": "Provoque la désorientation des butineuses.", "deputes": 4},
	{"id": "sulfoxaflor", "nom": "Sulfoxaflor", "type": "Sulfoximine", "danger": 4, "desc": "Même mode d'action que les néonics.", "deputes": 6},
	{"id": "glyphosate", "nom": "Glyphosate", "type": "Herbicide", "danger": 3, "desc": "Perturbe le microbiote intestinal des abeilles.", "deputes": 5},
	{"id": "mancozebe", "nom": "Mancozèbe", "type": "Fongicide", "danger": 2, "desc": "Faible toxicité directe mais affecte le couvain.", "deputes": 3},
	{"id": "lambda", "nom": "Lambda-cyhalothrine", "type": "Pyréthrinoïde", "danger": 3, "desc": "Très répandu dans l'agriculture.", "deputes": 4},
	{"id": "paraquat", "nom": "Paraquat", "type": "Herbicide", "danger": 5, "desc": "Herbicide le plus toxique au monde.", "deputes": 10},
]

func _init():
	process_mode = Node.PROCESS_MODE_ALWAYS
	anchor_right = 1.0; anchor_bottom = 1.0

func _ready():
	var bg = TextureRect.new()
	bg.anchor_right = 1.0; bg.anchor_bottom = 1.0; bg.stretch_mode = 0
	var bgt = load("res://Assets/Sprites/UI/bg_assemblee.png")
	if bgt: bg.texture = bgt
	add_child(bg)
	
	var bs = StyleBoxFlat.new(); bs.bg_color = Color(0.08, 0.08, 0.15, 0.85)
	add_theme_stylebox_override("panel", bs)
	
	var m = MarginContainer.new(); m.anchor_right = 1.0; m.anchor_bottom = 1.0
	for s in ["left","top","right","bottom"]: m.add_theme_constant_override("margin_"+s, 20)
	add_child(m)
	
	var vb = VBoxContainer.new(); vb.anchor_right = 1.0; vb.anchor_bottom = 1.0; m.add_child(vb)
	
	# Header
	var top = HBoxContainer.new(); top.size_flags_horizontal = 3; vb.add_child(top)
	var tl = Label.new(); tl.text = "Assembl\u00e9e Nationale - Pesticides dangereux"
	tl.add_theme_font_size_override("font_size", 22)
	tl.add_theme_color_override("font_color", Color(0.9, 0.8, 0.2))
	tl.size_flags_horizontal = 3; top.add_child(tl)
	var bf = Button.new(); bf.text = "X"; bf.pressed.connect(_on_fermer); top.add_child(bf)
	
	# Sous-titre
	var st = Label.new()
	st.text = "Liste des pesticides autoris\u00e9s dangereux pour les abeilles - Chaque loi vot\u00e9e en interdit un."
	st.add_theme_font_size_override("font_size", 12)
	st.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vb.add_child(st)
	
	# Barre de recherche / statut
	var stat = Label.new()
	stat.name = "StatLois"
	stat.text = "Chargement..."
	stat.add_theme_font_size_override("font_size", 14)
	stat.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	vb.add_child(stat)
	
	# Scroll avec la liste
	var sc = ScrollContainer.new(); sc.name = "ScrollLois"; sc.size_flags_vertical = 3; vb.add_child(sc)

	var uc = VBoxContainer.new(); uc.size_flags_horizontal = 3; sc.add_child(uc)
	
	_build_all_cards(uc)
	_refresh_cards()
	
	# Bouton Reprendre
	var btn_box = HBoxContainer.new(); vb.add_child(btn_box)
	var reprendre = Button.new()
	reprendre.text = "▶ Reprendre la partie"
	reprendre.custom_minimum_size = Vector2(250, 40)
	reprendre.add_theme_font_size_override("font_size", 16)
	reprendre.pressed.connect(_on_fermer)
	btn_box.add_child(reprendre)

func _voter_pesticide(p):
	var dep = p.deputes
	if GameManager.deputes < dep: return
	if GameManager.lois_votees.has(p.id): return
	GameManager.deputes -= dep
	GameManager.lois_votees[p.id] = true
	GameManager.save()
	_refresh_cards()

func _build_all_cards(uc):
	for p in PESTICIDES:
		_build_card(uc, p)

func _build_card(uc, p):
	var card = Panel.new()
	card.custom_minimum_size = Vector2(0, 60)
	card.size_flags_horizontal = 3
	var cbs = StyleBoxFlat.new(); cbs.bg_color = Color(0.12, 0.12, 0.2)
	cbs.corner_radius_top_left = 8; cbs.corner_radius_top_right = 8
	cbs.corner_radius_bottom_left = 8; cbs.corner_radius_bottom_right = 8
	cbs.content_margin_left = 12; cbs.content_margin_top = 6; cbs.content_margin_bottom = 6
	card.add_theme_stylebox_override("panel", cbs); uc.add_child(card)
	
	var h = HBoxContainer.new(); h.size_flags_horizontal = 3; card.add_child(h)
	var v = VBoxContainer.new(); v.size_flags_horizontal = 3; h.add_child(v)
	
	var l1 = Label.new(); l1.text = p.nom + " (" + p.type + ")"
	l1.add_theme_font_size_override("font_size", 14)
	l1.add_theme_color_override("font_color", Color(1, 0.85, 0.4)); v.add_child(l1)
	
	var l2 = Label.new(); l2.text = p.desc
	l2.add_theme_font_size_override("font_size", 11)
	l2.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	l2.autowrap_mode = TextServer.AUTOWRAP_WORD; v.add_child(l2)
	
	var dang = HBoxContainer.new(); h.add_child(dang)
	for i in 5:
		var d = ColorRect.new(); d.size = Vector2(12, 12)
		if i < p.danger: d.color = Color(1, 0.3, 0.3)
		else: d.color = Color(0.3, 0.3, 0.3)
		dang.add_child(d)
	
	var dep_v = VBoxContainer.new(); h.add_child(dep_v)
	var dep_l = Label.new()
	dep_l.text = "👤 " + str(p.deputes)
	dep_l.add_theme_font_size_override("font_size", 12)
	dep_l.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	dep_v.add_child(dep_l)
	
	var deja_vote = GameManager.lois_votees.has(p.id)
	var peut = GameManager.deputes >= p.deputes and not deja_vote
	var btn = Button.new()
	btn.text = "Voter" if peut else "👤 " + str(p.deputes)
	btn.disabled = not peut
	btn.custom_minimum_size = Vector2(70, 30)
	if peut:
		btn.add_theme_color_override("font_color", Color(0.3, 1, 0.3))
		btn.pressed.connect(_voter_pesticide.bind(p))
	else:
		btn.add_theme_color_override("font_color", Color(0.6, 0.3, 0.3))
	dep_v.add_child(btn)

func _refresh_cards():
	var stat = get_node_or_null("StatLois")
	if stat:
		var votes = 0
		for pest in PESTICIDES:
			if GameManager.lois_votees.has(pest.id): votes += 1
		stat.text = "Lois votées: " + str(votes) + " / " + str(PESTICIDES.size())
		if votes >= PESTICIDES.size():
			GameManager.stats.victoire = true
			GameManager.save()
			var vb = get_node_or_null("VBoxContainer")
			if vb:
				var vic = Label.new()
				vic.text = "🎉 VICTOIRE ! Tous les pesticides interdits !\nLes abeilles sont sauvees !"
				vic.add_theme_font_size_override("font_size", 18)
				vic.add_theme_color_override("font_color", Color(0.3, 1, 0.3))
				vic.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				vb.add_child(vic)
	var sc = get_node_or_null("ScrollLois")
	if sc:
		for c in sc.get_children(): c.queue_free()
		var uc = VBoxContainer.new(); uc.size_flags_horizontal = 3; sc.add_child(uc)
		_build_all_cards(uc)
func _on_fermer():
	ferme.emit()
	queue_free()
