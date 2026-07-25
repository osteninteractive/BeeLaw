extends Node

var _main: Node2D

func init(main: Node2D):
	_main = main

func spawn_frelon():
	var f = Area2D.new(); f.position = Vector2(1400, randf_range(100, 600))
	f.input_pickable = true; _main.add_child(f); f.add_to_group("frelons")
	f.set_meta("hp", 15); f.set_meta("tue", false)
	var spr = _creer_sprite_frelon(); f.add_child(spr)
	var col = CollisionShape2D.new()
	var rect = RectangleShape2D.new(); rect.size = Vector2(200, 200)
	col.shape = rect; f.add_child(col)
	var buzz = load("res://Assets/Audio/hornet_buzz.wav")
	if buzz: var p = AudioStreamPlayer2D.new(); p.stream = buzz; f.add_child(p); p.play()
	var tw = create_tween()
	tw.tween_property(f, "position", Vector2(-100, randf_range(100, 600)), 8.0)
	tw.tween_callback(func(): if is_instance_valid(f): f.queue_free())

func _creer_sprite_frelon() -> AnimatedSprite2D:
	var spr = AnimatedSprite2D.new(); spr.name = "AnimatedSprite2D"
	var sheet = SpriteFrames.new(); sheet.add_animation("fly")
	for i in 3:
		var f = load("res://Assets/Sprites/Bees/frelon_frames/frame_" + str(i+1) + ".png")
		if f: sheet.add_frame("fly", f)
	sheet.set_animation_speed("fly", 8)
	spr.sprite_frames = sheet; spr.play("fly"); spr.scale = Vector2(0.3, 0.3)
	return spr

func spawn_ours():
	if GameManager.evenement_actif and GameManager.evenement_actif.id == "ours_dodo": return
	var o = Area2D.new(); o.position = Vector2(1400, randf_range(80, 550))
	o.input_pickable = true; _main.add_child(o); o.add_to_group("ours")
	o.set_meta("hp", 60); o.set_meta("tue", false); o.set_meta("eating", false)
	var spr = _creer_sprite_ours(); o.add_child(spr)
	var col = CollisionShape2D.new()
	var rect = RectangleShape2D.new(); rect.size = Vector2(200, 200)
	col.shape = rect; o.add_child(col)
	var roar = load("res://Assets/Audio/bear_roar.mp3")
	if roar: var p = AudioStreamPlayer2D.new(); p.stream = roar; p.max_distance = 2000; o.add_child(p); p.play()
	var tw = create_tween()
	tw.tween_property(o, "position", Vector2(250, 560), 6.0).set_ease(Tween.EASE_IN_OUT)
	await tw.finished
	if not is_instance_valid(o) or o.get_meta("tue"): return
	spr.play("eat"); o.set_meta("eating", true)
	while is_instance_valid(o) and not o.get_meta("tue") and GameManager.honey > 0:
		GameManager.honey -= 1; await get_tree().create_timer(1.0).timeout
	if is_instance_valid(o) and is_instance_valid(spr):
		if o.get_meta("tue"): o.queue_free(); return
		spr.play("walk")
	if not is_instance_valid(o): return
	var t2 = create_tween()
	t2.tween_property(o, "position", Vector2(-100, o.position.y), 3.0)
	await t2.finished
	if is_instance_valid(o): o.queue_free()

func _creer_sprite_ours() -> AnimatedSprite2D:
	var spr = AnimatedSprite2D.new(); spr.name = "AnimatedSprite2D"
	var sheet = SpriteFrames.new(); sheet.add_animation("walk"); sheet.add_animation("eat")
	for i in 4:
		var f = load("res://Assets/Sprites/Buildings/bear_frames/bear_walk_" + str(i+1) + ".png")
		if f: sheet.add_frame("walk", f)
		var g = load("res://Assets/Sprites/Buildings/bear_frames/bear_eat_" + str(i+1) + ".png")
		if g: sheet.add_frame("eat", g)
	sheet.set_animation_speed("walk", 6); sheet.set_animation_speed("eat", 4)
	spr.sprite_frames = sheet; spr.play("walk"); spr.scale = Vector2(0.35, 0.35)
	return spr
