extends Panel

var _visible = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	anchor_right = 1.0; anchor_bottom = 1.0
	
	var bs = StyleBoxFlat.new(); bs.bg_color = Color(0, 0, 0, 0.85)
	add_theme_stylebox_override("panel", bs)
	
	var vb = VBoxContainer.new(); vb.position = Vector2(20, 20); add_child(vb)
	
	var titre = Label.new(); titre.text = "🐞 DEBUG PANEL"; titre.add_theme_font_size_override("font_size", 20)
	titre.add_theme_color_override("font_color", Color(0.3, 1, 0.3)); vb.add_child(titre)
	
	var ligne = func(txt): var l = Label.new(); l.text = txt; l.add_theme_font_size_override("font_size", 12); l.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8)); vb.add_child(l)
	
	var btn = func(txt, cb): var b = Button.new(); b.text = txt; b.custom_minimum_size = Vector2(200, 28); b.pressed.connect(cb); vb.add_child(b)
	
	btn.call("+1000 Miel", func(): GameManager.honey += 1000; GameManager.honey_change.emit(GameManager.honey))
	btn.call("+20 Deputes", func(): GameManager.deputes += 20)
	btn.call("+10 Ouvrieres", _debug_ouvrieres)
	btn.call("Prestige (Game Over)", func(): get_node("/root/Main/Main")._on_restart())
	btn.call("Guerriere +1 slot", func(): GameManager.shop_niveaux["guerriere_slots"] = GameManager.shop_niveaux.get("guerriere_slots", 0) + 1)
	btn.call("Declencher Ours", func(): get_node("/root/Main/Main")._spawn_ours())
	btn.call("Declencher Frelon", func(): get_node("/root/Main/Main")._spawn_frelon())
	btn.call("Declencher Pluie", func(): _declencher_evt("pluie", "🌧 Printemps humide", 20))
	btn.call("Declencher Canicule", func(): _declencher_evt("canicule", "☀ Canicule", 20))
	btn.call("Declencher Floraison", func(): _declencher_evt("floraison", "🌸 Floraison", 20))
	btn.call("Declencher Ours dodo", func(): _declencher_evt("ours_dodo", "🐻 Ours endormi", 20))
	btn.call("Declencher Bio", func(): _declencher_evt("bio", "🚜 Agriculteur bio", 20))
	btn.call("Sauvegarder", func(): GameManager.save(); _show_dbg("Sauvegarde OK"))
	btn.call("Charger", func(): GameManager.load_save(); _show_dbg("Chargement OK"))
	btn.call("Reset Sauvegarde", func(): GameManager.save_reset(); _show_dbg("Reset OK"))

func _declencher_evt(id: String, nom: String, duree: float):
	GameManager.evenement_actif = {"id": id, "nom": nom, "duree": duree}
	GameManager.timer_evenement = duree
	GameManager.evenement.emit(nom, duree)
	_show_dbg("Evenement: " + nom)

func _show_dbg(msg: String):
	var l = Label.new(); l.text = msg; l.position = Vector2(400, 350)
	l.add_theme_font_size_override("font_size", 24)
	l.add_theme_color_override("font_color", Color(0.3, 1, 0.3))
	add_child(l)
	var t = create_tween(); t.tween_property(l, "modulate:a", 0.0, 1.5).set_delay(1.0)
	t.tween_callback(l.queue_free)

func _debug_ouvrieres():
	for i in range(10):
		GameManager.acheter_ouvriere()

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_F12:
		_visible = not _visible; visible = _visible
