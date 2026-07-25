extends Panel

signal ferme

const TR = {
	"fr": {
		"titre_param": "Param\u00e8tres",
		"langue": "Langue",
		"francais": "Fran\u00e7ais",
		"anglais": "English",
		"fermer": "Fermer",
	},
	"en": {
		"titre_param": "Settings",
		"langue": "Language",
		"francais": "French",
		"anglais": "English",
		"fermer": "Close",
	}
}

func _init():
	process_mode = Node.PROCESS_MODE_ALWAYS
	anchor_right = 1.0; anchor_bottom = 1.0

func _ready():
	var bg = Panel.new()
	bg.anchor_right = 1.0; bg.anchor_bottom = 1.0
	var obs = StyleBoxFlat.new(); obs.bg_color = Color(0, 0, 0, 0.7)
	bg.add_theme_stylebox_override("panel", obs)
	add_child(bg)
	
	var vb = VBoxContainer.new(); vb.position = Vector2(440, 200); add_child(vb)
	
	var tl = Label.new(); tl.text = _t("titre_param"); tl.add_theme_font_size_override("font_size", 24)
	tl.add_theme_color_override("font_color", Color(0.9, 0.8, 0.2)); vb.add_child(tl)
	
	# Langue
	var lang_box = HBoxContainer.new(); vb.add_child(lang_box)
	var ll = Label.new(); ll.text = _t("langue") + " : "
	ll.add_theme_font_size_override("font_size", 16); ll.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	lang_box.add_child(ll)
	
	var curr = "fr"
	if GameManager.langue == "en": curr = "en"
	
	var btn_fr = Button.new(); btn_fr.text = _t("francais"); btn_fr.custom_minimum_size = Vector2(100, 30)
	btn_fr.disabled = GameManager.langue == "fr"
	btn_fr.pressed.connect(_set_lang.bind("fr", btn_fr, null))
	lang_box.add_child(btn_fr)
	
	var btn_en = Button.new(); btn_en.text = _t("anglais"); btn_en.custom_minimum_size = Vector2(100, 30)
	btn_en.disabled = GameManager.langue == "en"
	btn_en.pressed.connect(_set_lang.bind("en", btn_fr, btn_en))
	lang_box.add_child(btn_en)
	
	# Fermer
	var close_btn = Button.new(); close_btn.text = _t("fermer"); close_btn.custom_minimum_size = Vector2(200, 40)
	close_btn.position = Vector2(0, 80); close_btn.pressed.connect(_on_close)
	vb.add_child(close_btn)

func _t(key: String) -> String:
	var lang = GameManager.langue if GameManager.langue in TR else "fr"
	return TR[lang].get(key, key)

func _set_lang(lang: String, btn_fr: Button, btn_en: Button):
	GameManager.langue = lang
	GameManager.save()
	# Refresh: recrer la scene
	var p = get_parent()
	if p:
		var inst = preload("res://Scenes/Menu/SettingsPanel.gd").new()
		inst.ferme.connect(_on_close)
		p.add_child(inst)
		queue_free()

func _on_close():
	ferme.emit()
	queue_free()
