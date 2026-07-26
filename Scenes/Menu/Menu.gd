extends Control

func _ready():
	# Fond
	var bg = TextureRect.new()
	bg.anchor_right = 1.0; bg.anchor_bottom = 1.0
	bg.stretch_mode = 0
	var bgt = load("res://Assets/Sprites/UI/bg_prairie.png")
	if bgt: bg.texture = bgt
	add_child(bg)
	
	# Overlay sombre
	var ov = Panel.new()
	ov.anchor_right = 1.0; ov.anchor_bottom = 1.0
	var bs = StyleBoxFlat.new(); bs.bg_color = Color(0, 0, 0, 0.5)
	ov.add_theme_stylebox_override("panel", bs)
	add_child(ov)
	
	# Icone du jeu en haut centre
	var icon = TextureRect.new()
	var it = load("res://Assets/Sprites/UI/title_icon.png")
	if it: icon.texture = it; icon.stretch_mode = 0
	icon.position = Vector2(390, 50); icon.scale = Vector2(0.8, 0.8)
	add_child(icon)
	
	# Abeille décorative
	var ab = Sprite2D.new()
	var abt = load("res://Assets/Sprites/Bees/bee_worker.png")
	if abt: ab.texture = abt
	ab.scale = Vector2(0.4, 0.4)
	ab.position = Vector2(640, 420)
	add_child(ab)
	var tw = create_tween().set_loops()
	tw.tween_property(ab, "scale", Vector2(0.3, 0.26), 0.08)
	tw.tween_property(ab, "scale", Vector2(0.3, 0.3), 0.08)
	
	# Bouton Play
	var btn = Button.new()
	btn.text = "Play"
	btn.position = Vector2(540, 500)
	btn.custom_minimum_size = Vector2(200, 50)
	btn.add_theme_font_size_override("font_size", 24)
	btn.pressed.connect(_on_play)
	add_child(btn)
	
	# Bouton Parametres
	var set_btn = Button.new()
	set_btn.text = "\u2699\ufe0f"
	set_btn.position = Vector2(20, 20)
	set_btn.custom_minimum_size = Vector2(40, 40)
	set_btn.add_theme_font_size_override("font_size", 20)
	set_btn.pressed.connect(_open_settings)
	add_child(set_btn)
	
	# Version
	var ver = Label.new()
	ver.text = "v0.1"
	ver.add_theme_font_size_override("font_size", 12)
	ver.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	ver.position = Vector2(620, 680)
	add_child(ver)
	
	# Bouton Credits (?)
	var btn_credits = Button.new()
	btn_credits.text = "?"
	btn_credits.position = Vector2(1240, 10)
	btn_credits.custom_minimum_size = Vector2(30, 30)
	btn_credits.add_theme_font_size_override("font_size", 16)
	btn_credits.pressed.connect(_show_credits)
	add_child(btn_credits)
	
	# Musique de fond
	var player = AudioStreamPlayer.new()
	var music = load("res://Assets/Audio/title_music.mp3")
	if music:
		player.stream = music
		player.autoplay = true
		add_child(player)
	
	# Bouton Reset (petit, discret)
	var reset = Button.new()
	reset.text = "Reset"
	reset.position = Vector2(10, 10)
	reset.custom_minimum_size = Vector2(80, 25)
	reset.add_theme_font_size_override("font_size", 11)
	reset.pressed.connect(_on_reset)
	add_child(reset)

func _on_reset():
	GameManager.reset_all_progress()
	_show_popup("Progression reinitialisee")

func _show_popup(msg: String):
	var p = Label.new()
	p.text = msg
	p.position = Vector2(540, 600)
	p.add_theme_font_size_override("font_size", 24)
	p.add_theme_color_override("font_color", Color(1, 0.9, 0.3))
	add_child(p)
	var t = create_tween()
	t.tween_property(p, "modulate:a", 0.0, 2.0)
	t.tween_callback(p.queue_free)

func _on_play():
	get_tree().change_scene_to_file("res://Scenes/Main/Main.tscn")

func _show_credits():
	var popup = Panel.new()
	popup.anchor_right = 1.0; popup.anchor_bottom = 1.0
	var bs = StyleBoxFlat.new(); bs.bg_color = Color(0, 0, 0, 0.85)
	popup.add_theme_stylebox_override("panel", bs)
	add_child(popup)
	
	var text = "CREDITS\n\nSons:\n- Frelon: \"bee bee gun shot at piano.wav\" by dcolvin\n  https://freesound.org/s/193893/  (CC BY 3.0)\n- Abeille: \"Gun Shot 1 8 Bit.wav\" by Mrthenoronha\n  https://freesound.org/s/507018/  (CC BY-NC 4.0)\n\nD\u00e9veloppement:\n- Game Design: Morgan\n- Code: Hermes Agent (Nous Research)\n- Moteur: Godot 4.7\n\nSprites g\u00e9n\u00e9r\u00e9s via ChatGPT"
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	label.position = Vector2(400, 200)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.custom_minimum_size = Vector2(500, 400)
	popup.add_child(label)
	
	var close = Button.new()
	close.text = "Fermer"
	close.position = Vector2(590, 600)
	close.pressed.connect(popup.queue_free)
	popup.add_child(close)

func _open_settings():
	var p = preload("res://Scenes/Menu/SettingsPanel.gd").new()
	p.ferme.connect(p.queue_free)
	add_child(p)
