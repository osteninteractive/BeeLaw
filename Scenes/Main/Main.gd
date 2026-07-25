extends Node2D

# ===== VARIABLES =====
var _honey_label: Label; var _popup: Label; var _btn_upgrade: Button
var _en_vol: int = 0; var _ruche_pos: Vector2 = Vector2(160, 580)
var _upgrades_instance; var _assemblee_instance; var _gameover_instance
var _ouvrieres = []; var _pause_overlay; var _est_pause = false
var _barre_ruche: ProgressBar; var _sante_ruche = 100.0; var _sante_max = 100.0
var _label_pollen: Label; var _evenement_label: Label; var _skill_buttons = {}
var _perf_label: Label
var _flower_mgr; var _threat_mgr; var _bee_mgr
var _gameover_layer: CanvasLayer
var _guerriere_en_vol := false
const DEBUG_MODE := false

func _ready():
	_sante_max = GameManager.get_vie_ruche_max(); _sante_ruche = _sante_max
	
	# Managers (AVANT _spawn_fleurs)
	var fm = preload("res://Scripts/FlowerManager.gd").new(); add_child(fm); _flower_mgr = fm
	var tm = preload("res://Scripts/ThreatManager.gd").new(); add_child(tm); tm.init(self); _threat_mgr = tm
	var bm = preload("res://Scripts/BeeManager.gd").new(); add_child(bm); bm.init(self); _bee_mgr = bm
	
	_construire(); _spawn_fleurs()
	GameManager.honey_change.connect(_maj_honey)
	GameManager.pollen_change.connect(_maj_pollen)
	GameManager.pollen_change.connect(_maj_pollen)
	GameManager.evenement.connect(_on_evenement)
	GameManager.biome_change.connect(_changer_biome)
	
	_maj_honey(GameManager.honey); _maj_pollen(GameManager.pollen)
	_changer_biome(GameManager.biome_actuel)

	# Debug panel (F12)
	_add_debug()
	# Perf
	_perf_label = Label.new(); _perf_label.position = Vector2(10, 700)
	_perf_label.add_theme_font_size_override("font_size", 10)
	_perf_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 0.7))
	add_child(_perf_label)
	# Timers
	for t in [["ft", 60.0, _spawn_frelon], ["bt", 90.0, _spawn_ours], ["st", 1.0, _tick_sante], ["sk", 1.0, _tick_skills]]:
		var ti = Timer.new(); ti.wait_time = t[1]; ti.autostart = true; ti.timeout.connect(t[2]); add_child(ti)

func _construire():
	# Fond
	var bg = TextureRect.new(); bg.anchor_right = 1.0; bg.anchor_bottom = 1.0
	var bgt = load("res://Assets/Sprites/UI/bg_prairie.png")
	if bgt: bg.texture = bgt; add_child(bg)
	
	# Honey
	_honey_label = Label.new(); _honey_label.position = Vector2(20, 620)
	_honey_label.add_theme_font_size_override("font_size", 32)
	_honey_label.add_theme_color_override("font_color", Color(1, 1, 1))
	_honey_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	_honey_label.add_theme_constant_override("outline_size", 3)
	var hs = StyleBoxFlat.new(); hs.bg_color = Color(0, 0, 0, 0.7)
	hs.corner_radius_top_left = 8; hs.corner_radius_top_right = 8
	hs.corner_radius_bottom_left = 8; hs.corner_radius_bottom_right = 8
	hs.content_margin_left = 12; hs.content_margin_right = 12
	hs.content_margin_top = 6; hs.content_margin_bottom = 6
	_honey_label.add_theme_stylebox_override("normal", hs); add_child(_honey_label)
	
	# Pollen
	_label_pollen = Label.new(); _label_pollen.position = Vector2(20, 660)
	_label_pollen.add_theme_font_size_override("font_size", 20)
	_label_pollen.add_theme_color_override("font_color", Color(1, 0.9, 0.2))
	add_child(_label_pollen)
	
	# (progression desactivee)
	var pb = ProgressBar.new()
	pb.name = "ProgDollars"; pb.max_value = 1000
	pb.value = GameManager.honey_this_run % 1000
	pb.position = Vector2(200, 664); pb.custom_minimum_size = Vector2(250, 16)
	pb.show_percentage = false
	var pbg = StyleBoxFlat.new(); pbg.bg_color = Color(0.12, 0.12, 0.15, 0.9)
	pbg.corner_radius_top_left = 6; pbg.corner_radius_top_right = 6
	pbg.corner_radius_bottom_left = 6; pbg.corner_radius_bottom_right = 6
	pb.add_theme_stylebox_override("background", pbg)
	var pfl = StyleBoxFlat.new(); pfl.bg_color = Color(0.8, 0.7, 0.1)
	pfl.corner_radius_top_left = 6; pfl.corner_radius_top_right = 6
	pfl.corner_radius_bottom_left = 6; pfl.corner_radius_bottom_right = 6
	pb.add_theme_stylebox_override("fill", pfl)
	add_child(pb)
	var pl = Label.new()
	pl.name = "ProgLabel"; pl.text = "Next $: 1000 honey"
	pl.position = Vector2(205, 666); pl.add_theme_font_size_override("font_size", 10)
	pl.add_theme_color_override("font_color", Color(1, 1, 0.8)); add_child(pl)
	
	# Barre sante
	_barre_ruche = ProgressBar.new(); _barre_ruche.max_value = _sante_max
	_barre_ruche.value = _sante_ruche; _barre_ruche.position = Vector2(340, 5)
	_barre_ruche.custom_minimum_size = Vector2(600, 28); _barre_ruche.show_percentage = false
	var hbg = StyleBoxFlat.new(); hbg.bg_color = Color(0.15, 0.15, 0.15, 0.95)
	hbg.corner_radius_top_left = 10; hbg.corner_radius_top_right = 10
	hbg.corner_radius_bottom_left = 10; hbg.corner_radius_bottom_right = 10
	_barre_ruche.add_theme_stylebox_override("background", hbg)
	var hfl = StyleBoxFlat.new(); hfl.bg_color = Color(0.15, 0.8, 0.15)
	hfl.corner_radius_top_left = 10; hfl.corner_radius_top_right = 10
	hfl.corner_radius_bottom_left = 10; hfl.corner_radius_bottom_right = 10
	_barre_ruche.add_theme_stylebox_override("fill", hfl); add_child(_barre_ruche)
	var hl = Label.new(); hl.text = "🏠 Hive"; hl.position = Vector2(610, 10)
	hl.add_theme_font_size_override("font_size", 16)
	hl.add_theme_color_override("font_color", Color(1, 1, 1)); add_child(hl)
	
	# Animation pesticide a cote de la barre
	var pest = AnimatedSprite2D.new()
	var psheet = SpriteFrames.new(); psheet.add_animation("spray")
	for p_i in 3:
		var pf = load("res://Assets/Sprites/UI/pesticide_frames/frame_" + str(p_i+1) + ".png")
		if pf: psheet.add_frame("spray", pf)
	psheet.set_animation_speed("spray", 6)
	pest.sprite_frames = psheet; pest.play("spray")
	pest.scale = Vector2(0.16, 0.16)
	pest.position = Vector2(310, 25); add_child(pest)
	
	# Boutons
	_btn_upgrade = Button.new(); _btn_upgrade.text = "⬆ Upgrades"
	_btn_upgrade.position = Vector2(1100, 650); _btn_upgrade.custom_minimum_size = Vector2(160, 40)
	_btn_upgrade.pressed.connect(_open_upgrades); add_child(_btn_upgrade)
	var btn_ass = Button.new(); btn_ass.text = "📜 Assembl\u00e9e"
	btn_ass.position = Vector2(1100, 600); btn_ass.custom_minimum_size = Vector2(160, 40)
	btn_ass.pressed.connect(_open_assemblee); add_child(btn_ass)
	var btn_reset = Button.new(); btn_reset.text = "🔄 Restart"
	btn_reset.position = Vector2(1100, 10); btn_reset.custom_minimum_size = Vector2(160, 30)
	btn_reset.add_theme_font_size_override("font_size", 12)
	var rbs = StyleBoxFlat.new(); rbs.bg_color = Color(0.3, 0.08, 0.08)
	rbs.corner_radius_top_left = 6; rbs.corner_radius_top_right = 6
	rbs.corner_radius_bottom_left = 6; rbs.corner_radius_bottom_right = 6
	btn_reset.add_theme_stylebox_override("normal", rbs)
	btn_reset.pressed.connect(_on_restart); add_child(btn_reset)
	
	# Pause
	var btn_pause = Button.new(); btn_pause.text = "⏸"
	btn_pause.position = Vector2(10, 10)
	btn_pause.custom_minimum_size = Vector2(40, 30)
	btn_pause.pressed.connect(_toggle_pause); add_child(btn_pause)
	_pause_overlay = Panel.new(); _pause_overlay.anchor_right = 1.0; _pause_overlay.anchor_bottom = 1.0
	_pause_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	var ps = StyleBoxFlat.new(); ps.bg_color = Color(0, 0, 0, 0.7)
	_pause_overlay.add_theme_stylebox_override("panel", ps); _pause_overlay.visible = false; add_child(_pause_overlay)
	var pt = Label.new(); pt.text = "PAUSED"; pt.process_mode = Node.PROCESS_MODE_ALWAYS
	pt.add_theme_font_size_override("font_size", 48)
	pt.add_theme_color_override("font_color", Color(1, 1, 1))
	pt.position = Vector2(540, 280); _pause_overlay.add_child(pt)
	var br = Button.new(); br.text = "▶ Reprendre"; br.process_mode = Node.PROCESS_MODE_ALWAYS
	br.position = Vector2(560, 350); br.custom_minimum_size = Vector2(160, 45)
	br.add_theme_font_size_override("font_size", 18)
	br.pressed.connect(_toggle_pause); _pause_overlay.add_child(br)
	
	# Evenement
	_evenement_label = Label.new(); _evenement_label.position = Vector2(400, 60)
	_evenement_label.add_theme_font_size_override("font_size", 20)
	_evenement_label.add_theme_color_override("font_color", Color(1, 0.9, 0.3))
	_evenement_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	_evenement_label.add_theme_constant_override("outline_size", 2)
	_evenement_label.visible = false; add_child(_evenement_label)
	
	# Popup
	_popup = Label.new(); _popup.position = Vector2(500, 100)
	_popup.add_theme_font_size_override("font_size", 28)
	_popup.add_theme_color_override("font_color", Color(1, 0.9, 0.2))
	_popup.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	_popup.add_theme_constant_override("outline_size", 2)
	_popup.modulate.a = 0.0; add_child(_popup)
	
	# Queen
	var reine = Sprite2D.new(); var rt = load("res://Assets/Sprites/Bees/bee_queen.png")
	if rt: reine.texture = rt; reine.scale = Vector2(0.3, 0.3)
	reine.position = Vector2(640, 300); add_child(reine)
	
	# Bulle reine
	var bulle = Panel.new(); bulle.name = "BulleReine"
	bulle.position = Vector2(680, 160); bulle.custom_minimum_size = Vector2(260, 70)
	var bs = StyleBoxFlat.new(); bs.bg_color = Color(1, 1, 0.95)
	bs.border_color = Color(0.2, 0.2, 0.2)
	bs.border_width_left = 2; bs.border_width_top = 2; bs.border_width_right = 2; bs.border_width_bottom = 2
	bs.corner_radius_top_left = 12; bs.corner_radius_top_right = 12
	bs.corner_radius_bottom_left = 4; bs.corner_radius_bottom_right = 12
	bs.content_margin_left = 10; bs.content_margin_right = 10; bs.content_margin_top = 8; bs.content_margin_bottom = 8
	bulle.add_theme_stylebox_override("panel", bs); bulle.modulate.a = 0.0; add_child(bulle)
	var q = ColorRect.new(); q.name = "QueueBulle"; q.color = Color(1, 1, 0.95)
	q.size = Vector2(16, 16); q.position = Vector2(30, 70)
	q.rotation = 0.785; q.modulate.a = 0.0; add_child(q)
	var rl = Label.new(); rl.name = "ReineDialogue"
	rl.text = "..."; rl.add_theme_font_size_override("font_size", 13)
	rl.add_theme_color_override("font_color", Color(0.05, 0.05, 0.05))
	rl.autowrap_mode = TextServer.AUTOWRAP_WORD; rl.custom_minimum_size = Vector2(240, 50)
	bulle.add_child(rl)
	
	# Queen Skills
	var sk_pos = Vector2(400, 680)
	var skills_data = [["cri_royal", "👑 Cri Royal", 1], ["ponte", "🥚 Ponte", 2], ["essaim", "🐝 Essaim", 3]]
	for sd in skills_data:
		var b = Button.new(); b.name = "Skill" + str(sd[2]); b.text = sd[1]
		b.position = sk_pos; b.custom_minimum_size = Vector2(140, 35)
		b.add_theme_font_size_override("font_size", 11)
		b.pressed.connect(_use_skill.bind(sd[0]))
		add_child(b); _skill_buttons[sd[0]] = b
		sk_pos.x += 150
	
	# Collection button
	var col_btn = Button.new(); col_btn.text = "🏛 Musée"
	col_btn.position = Vector2(1100, 550); col_btn.custom_minimum_size = Vector2(160, 30)
	col_btn.pressed.connect(_open_collection); add_child(col_btn)
	
	# Hive
	var hive = Sprite2D.new(); var ht = load("res://Assets/Sprites/Buildings/hive.png")
	if ht: hive.texture = ht; hive.scale = Vector2(0.5, 0.5)
	hive.position = _ruche_pos; add_child(hive)

	var reines_repliques = [
		"Allez les filles, on butine !", "Le miel ne se fait pas tout seul...",
		"Encore un effort !", "Ces fleurs sont magnifiques aujourd'hui.",
		"Je sens le printemps arriver.", "Mon petit doigt me dit qu'on va cartonner.",
		"Travaillez, travaillez !", "Le miel est mon sang, les fleurs mon royaume.",
		"Pas de repos pour les abeilles !", "La ruche a besoin de vous.",
		"Chaque goutte compte.", "J'ai vu un super champ de lavande au loin.",
		"Les frelons rôdent...", "Protégez la ruche !",
		"Encore 1000 honey et on pourra s'agrandir.", "Je suis fière de mon essaim.",
		"Bourdonnez plus fort !", "L'avenir est dans le bio.",
		"Les pesticides nous tuent... Résistons !", "Ce champ de colza est incroyable.",
		"La nature est belle, protégeons-la.", "Butinez, mes belles !",
		"Un jour, nous aurons la paix.", "Le miel coule à flots ! 🍯",
		"Ensemble, nous sommes invincibles !", "Cette ruche est la meilleure."
	]

func _process(delta):
	GameManager._process_skills(delta)
	GameManager._process_evenements(delta)
	_update_skill_buttons()
	if _perf_label and DEBUG_MODE:
		var fps = Engine.get_frames_per_second()
		var nodes = get_tree().get_node_count()
		var frelons = get_tree().get_nodes_in_group("frelons").size()
		var ours = get_tree().get_nodes_in_group("ours").size()
		_perf_label.text = "FPS: " + str(fps) + " | Nodes: " + str(nodes) + " | Frelons: " + str(frelons) + " | Ours: " + str(ours)

func _update_skill_buttons():
	for sid in _skill_buttons:
		var b = _skill_buttons[sid]
		var sk = GameManager.queen_skills[sid]
		if sk.timer > 0:
			b.text = sk.nom + " (" + str(int(ceil(sk.timer))) + "s)"
			b.disabled = true
		else:
			b.text = sk.nom; b.disabled = false

func _use_skill(skill_id):
	if _bee_mgr: _bee_mgr.utiliser_skill(skill_id)

func _add_debug():
	if not DEBUG_MODE: return
	var dp = preload("res://Scenes/Main/DebugPanel.gd").new()
	add_child(dp); dp.visible = false

func _show_popup(msg):
	_popup.text = msg; _popup.modulate.a = 1.0
	var t = create_tween()
	t.tween_property(_popup, "modulate:a", 0.0, 2.0).set_delay(0.8)

func _on_evenement(msg, duree):
	if msg == "":
		_evenement_label.visible = false; return
	_evenement_label.text = msg; _evenement_label.visible = true
	var t = create_tween()
	t.tween_property(_evenement_label, "modulate:a", 0.0, 2.0).set_delay(duree - 1)
	t.tween_callback(func(): _evenement_label.visible = false; _evenement_label.modulate.a = 1.0)

func _toggle_pause():
	_est_pause = not _est_pause
	_pause_overlay.visible = _est_pause
	get_tree().paused = _est_pause

func _on_restart():
	# Confirmation avant game over
	var confirm = Panel.new()
	confirm.name = "ConfirmPanel"
	confirm.anchor_right = 1.0; confirm.anchor_bottom = 1.0
	var cbg = StyleBoxFlat.new(); cbg.bg_color = Color(0, 0, 0, 0.85)
	confirm.add_theme_stylebox_override("panel", cbg)
	confirm.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(confirm)
	
	var ct = Label.new()
	ct.text = "Tout recommencer ?\nLe pollen est conserve\u00e9s."
	ct.add_theme_font_size_override("font_size", 22)
	ct.add_theme_color_override("font_color", Color(1, 1, 1))
	ct.position = Vector2(460, 300)
	confirm.add_child(ct)
	
	var yb = Button.new()
	yb.text = "Oui"
	yb.position = Vector2(520, 370); yb.custom_minimum_size = Vector2(100, 40)
	yb.pressed.connect(_confirm_restart)
	confirm.add_child(yb)
	
	var nb = Button.new()
	nb.text = "Non"
	nb.position = Vector2(640, 370); nb.custom_minimum_size = Vector2(100, 40)
	nb.pressed.connect(confirm.queue_free)
	confirm.add_child(nb)

func _confirm_restart():
	var c = get_node_or_null("ConfirmPanel")
	if c: c.queue_free()
	_open_gameover()

func _open_gameover():
	if _gameover_instance: return
	_pause_overlay.visible = false; get_tree().paused = true
	var scene = load("res://Scenes/GameOver/GameOverScreen.tscn")
	if not scene: push_error("Impossible de charger GameOverScreen.tscn"); return
	_gameover_layer = CanvasLayer.new(); _gameover_layer.layer = 100
	add_child(_gameover_layer)
	_gameover_instance = scene.instantiate()
	_gameover_instance.ferme.connect(_close_gameover)
	_gameover_layer.add_child(_gameover_instance)

func _close_gameover():
	get_tree().paused = false
	GameManager.restart()
	if _gameover_layer:
		_gameover_layer.queue_free()
	_gameover_layer = null
	_gameover_instance = null
	get_tree().call_deferred("reload_current_scene")

func _play_shoot_sound():
	var s = load("res://Assets/Audio/shoot.wav")
	if s:
		var p = AudioStreamPlayer2D.new(); p.stream = s; add_child(p); p.play(); p.finished.connect(p.queue_free)

func _spawn_blue_bee(target: Vector2):
	if _bee_mgr:
		_bee_mgr.spawn_blue_bee(target)
		_guerriere_en_vol = true

func _maj_honey(_v):
	if _honey_label: _honey_label.text = "🍯 " + str(GameManager.honey)
	var pb = get_node_or_null("ProgDollars")
	if pb: pb.value = GameManager.honey_this_run % 1000
	var pl = get_node_or_null("ProgLabel")
	if pl: pl.text = "Next $: " + str(1000 - (GameManager.honey_this_run % 1000)) + " honey"

func _maj_pollen(v):
	if _label_pollen: _label_pollen.text = "Pollen: " + str(GameManager.pollen)

func _changer_biome(biome_id):
	var bg = get_node_or_null("TextureRect")
	if not bg: return
	var paths = ["res://Assets/Sprites/UI/bg_prairie.png", "res://Assets/Sprites/UI/bg_prairie.png",
		"res://Assets/Sprites/UI/bg_prairie.png","res://Assets/Sprites/UI/bg_prairie.png",
		"res://Assets/Sprites/UI/bg_prairie.png","res://Assets/Sprites/UI/bg_prairie.png",
		"res://Assets/Sprites/UI/bg_prairie.png","res://Assets/Sprites/UI/bg_prairie.png"]
	if biome_id < paths.size():
		var t = load(paths[biome_id])
		if t: bg.texture = t

func _tick_sante():
	if _est_pause: return
	var mult = GameManager.get_pesticide_mult()
	_sante_ruche -= (100.0 / 480.0) * mult  # 8min base
	if _barre_ruche:
		_barre_ruche.max_value = GameManager.get_vie_ruche_max()
		_barre_ruche.value = max(0, _sante_ruche)
		if _sante_ruche < _barre_ruche.max_value * 0.3:
			_barre_ruche.modulate = Color(1, _sante_ruche / (_barre_ruche.max_value * 0.3) * 0.4 + 0.3, 0.3)
	if _sante_ruche <= 0: _open_gameover()

func _tick_skills():
	pass  # Skills handled in _process

# ===== UNHANDLED INPUT =====
func _unhandled_input(event):
	if _upgrades_instance or _assemblee_instance or _gameover_instance or _est_pause or _en_vol >= GameManager.get_max_butineuse(): return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var pos = get_global_mouse_position()
		# Check frelons
		for f in get_tree().get_nodes_in_group("frelons"):
			if not is_instance_valid(f) or f.get_meta("tue"): continue
			if f.position.distance_to(pos) < 120:
				_clic_frelon(f); return
		# Check ours
		for o in get_tree().get_nodes_in_group("ours"):
			if not is_instance_valid(o) or o.get_meta("tue"): continue
			if o.position.distance_to(pos) < 120:
				_clic_ours(o); return
		# Check fleur
		var fleur_idx = -1
		for fi in range(_flower_mgr._fleure_areas.size() if _flower_mgr else 0):
			if _flower_mgr and fi < _flower_mgr._fleurs_hp.size() and _flower_mgr._fleurs_hp[fi] <= 0: continue
			if _flower_mgr and fi < _flower_mgr._fleure_areas.size() and _flower_mgr._fleure_areas[fi].position.distance_to(pos) < 60:
				fleur_idx = fi; break
		if fleur_idx < 0:
			fleur_idx = _fleur_vivante()
		if fleur_idx >= 0:
			_envoyer_abeille(fleur_idx)

func _envoyer_abeille(fleur_idx):
	if fleur_idx < 0: return
	_en_vol += 1; GameManager.stats.clics_total += 1
	GameManager.honey_change.emit(GameManager.honey)
	# La reine parle
	if GameManager.stats.clics_total % 10 == 0: _parler_reine()
	
	var bee = Sprite2D.new(); var bt = load("res://Assets/Sprites/Bees/bee_worker.png")
	if bt: bee.texture = bt; bee.scale = Vector2(0.12, 0.12)
	bee.position = Vector2(640, 300); add_child(bee)
	
	# Vol vers la fleur
	var fd = _flower_mgr.get_data(fleur_idx) if _flower_mgr else null
	if fd == null: return
	var fp = _fleur_pos(fleur_idx) + Vector2(0, -20)
	var t1 = create_tween()
	t1.tween_property(bee, "position", fp, 0.5).set_ease(Tween.EASE_OUT)
	await t1.finished
	if not is_instance_valid(bee): return
	GameManager.stats.fleurs_visitees += 1
	GameManager.stats.km_parcourus += 0.05
	var nectar_fleur = 0
	if _flower_mgr:
		nectar_fleur = _flower_mgr.recolter(fleur_idx)
	if nectar_fleur <= 0:
		bee.queue_free(); _en_vol -= 1; return
	
	var mult = GameManager.get_multiplicateur_recolte()
	var gain = int(ceil(GameManager.get_puissance_clic() * nectar_fleur * mult))
	var click_spd = GameManager.get_vitesse_click()
	var t2 = create_tween()
	t2.tween_property(bee, "position", _ruche_pos + Vector2(0, -30), click_spd).set_ease(Tween.EASE_IN)
	await t2.finished
	if not is_instance_valid(bee): return
	
	GameManager.honey += gain; bee.queue_free()
	_en_vol -= 1

func _parler_reine():
	var repliques = [
		"Allez les filles, on butine !", "Le miel ne se fait pas tout seul...",
		"Encore un effort !", "Ces fleurs sont magnifiques aujourd'hui.",
		"Je sens le printemps arriver.", "Mon petit doigt me dit qu'on va cartonner.",
		"Travaillez, travaillez !", "Le miel est mon sang, les fleurs mon royaume.",
		"Pas de repos pour les abeilles !", "La ruche a besoin de vous.",
		"Chaque goutte compte.", "J'ai vu un super champ de lavande au loin.",
		"Les frelons rôdent...", "Protégez la ruche !",
		"Encore 1000 honey et on pourra s'agrandir.", "Je suis fière de mon essaim.",
		"Bourdonnez plus fort !", "L'avenir est dans le bio.",
		"Les pesticides nous tuent... Résistons !", "Ce champ de colza est incroyable.",
		"La nature est belle, protégeons-la.", "Butinez, mes belles !",
		"Un jour, nous aurons la paix.", "Le miel coule à flots ! 🍯",
		"Ensemble, nous sommes invincibles !"
	]
	var bulle = get_node_or_null("BulleReine"); var queue = get_node_or_null("QueueBulle")
	if not bulle: return
	var msg = repliques[randi() % repliques.size()]
	var label = bulle.get_node_or_null("ReineDialogue")
	if label: label.text = msg
	bulle.modulate.a = 1.0
	if queue: queue.modulate.a = 1.0
	var t = create_tween()
	t.tween_property(bulle, "modulate:a", 0.0, 3.5).set_delay(2.5)
	if queue: t.parallel().tween_property(queue, "modulate:a", 0.0, 3.5).set_delay(2.5)

# ===== FLEURS v2 =====
func _spawn_fleurs():
	if _flower_mgr: _flower_mgr.spawner(self, GameManager.biome_actuel)

func _fleur_vivante() -> int:
	if _flower_mgr: return _flower_mgr.get_vivante()
	return -1

func _fleur_pos(idx: int) -> Vector2:
	if _flower_mgr: return _flower_mgr.get_position(idx)
	return Vector2.ZERO

func _timer(sec: float):
	await get_tree().create_timer(sec).timeout


# ===== FRELON =====
func _spawn_frelon():
	if _threat_mgr: _threat_mgr.spawn_frelon()


func _clic_frelon(frelon):
	if _guerriere_en_vol: return
	_guerriere_en_vol = true
	var spr = frelon.get_node("AnimatedSprite2D")
	var hp = frelon.get_meta("hp") - 1; frelon.set_meta("hp", hp)
	_play_shoot_sound()
	_spawn_blue_bee(frelon.position)
	_show_popup("-1 HP (" + str(hp) + "/15)")
	if hp <= 0:
		frelon.set_meta("tue", true)
		GameManager.honey += 10 + GameManager.shop_niveaux.get("recompense_frelon", 0) * 5
		GameManager.stats.frelons_tues += 1
		var t = create_tween()
		t.tween_property(spr, "modulate", Color(1, 0, 0, 0), 0.2)
		t.parallel().tween_property(spr, "scale", Vector2(0, 0), 0.2)
		t.tween_callback(_show_popup.bind("+10 honey !"))
		t.tween_callback(frelon.queue_free)

# ===== OURS =====
func _spawn_ours():
	if _threat_mgr: _threat_mgr.spawn_ours()

func _clic_ours(ours):
	if _guerriere_en_vol: return
	_guerriere_en_vol = true
	var spr = ours.get_node("AnimatedSprite2D")
	var hp = ours.get_meta("hp") - 1; ours.set_meta("hp", hp)
	_play_shoot_sound()
	_spawn_blue_bee(ours.position)
	_show_popup("-1 Ours (" + str(hp) + "/60)")
	if hp <= 0:
		ours.set_meta("tue", true)
		GameManager.honey += 50 + GameManager.shop_niveaux.get("recompense_ours", 0) * 25
		GameManager.stats.ours_repousses += 1
		var t = create_tween()
		t.tween_property(spr, "modulate", Color(1, 0, 0, 0), 0.3)
		t.parallel().tween_property(spr, "scale", Vector2(0, 0), 0.3)
		t.tween_callback(_show_popup.bind("+50 honey !"))
		t.tween_callback(ours.queue_free)

# ===== UPGRADES =====
func _open_upgrades():
	if _upgrades_instance: return
	var cl = CanvasLayer.new(); cl.layer = 10; add_child(cl); _upgrades_instance = cl
	var tree = preload("res://Scripts/UI/UpgradeTree.gd").new()
	tree.ferme.connect(_close_upgrades)
	cl.add_child(tree)

func _close_upgrades():
	if _upgrades_instance: _upgrades_instance.queue_free(); _upgrades_instance = null

func _refresh_upgrades():
	_close_upgrades()
	_open_upgrades()

func _open_assemblee():
	if _assemblee_instance: return
	get_tree().paused = true
	var s = load("res://Scenes/Assemblee/AssembleeScreen.tscn")
	if s: _assemblee_instance = s.instantiate(); _assemblee_instance.ferme.connect(_close_assemblee); add_child(_assemblee_instance)

func _close_assemblee():
	if _assemblee_instance: _assemblee_instance.queue_free(); _assemblee_instance = null
	get_tree().paused = false

func _open_collection():
	# Placeholder pour le musée
	_show_popup("🏛 Musée - Collection en construction !")
