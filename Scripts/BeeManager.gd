extends Node

var _main: Node2D
var _ouvrieres = []

func init(main: Node2D):
	_main = main
	# Recrer ouvrieres sauvegardees
	for _i in range(GameManager.ouvrieres):
		ajouter_ouvriere(false)

func ajouter_ouvriere(compter = true):
	var wo = Sprite2D.new()
	var bt = load("res://Assets/Sprites/Bees/bee_worker.png")
	if bt: wo.texture = bt; wo.scale = Vector2(0.15, 0.15)
	wo.modulate = Color(0.8, 0.2, 0.2)
	wo.position = Vector2(160, 580) + Vector2(randf_range(-20, 20), randf_range(-20, 20))
	_main.add_child(wo)
	_ouvrieres.append({"node": wo})
	if compter: GameManager.ouvrieres += 1
	_demarrer_cycle(wo)

func _demarrer_cycle(wo):
	while is_instance_valid(wo):
		var fleur_idx = _main._fleur_vivante()
		if fleur_idx < 0: await get_tree().create_timer(1.0).timeout; continue
		
		var fp = _main._fleur_pos(fleur_idx) + Vector2(0, -20)
		var spd = GameManager.get_vitesse_ouvriere_mult()
		var t1 = create_tween()
		t1.tween_property(wo, "position", fp, 3.0 * spd).set_ease(Tween.EASE_IN_OUT)
		await t1.finished
		if not is_instance_valid(wo): return
		
		# Recolter la fleur
		var nectar_fleur = 0
		if _main._flower_mgr:
			nectar_fleur = _main._flower_mgr.recolter(fleur_idx)
		if nectar_fleur <= 0:
			# Fleur morte pendant le trajet, retour a la ruche puis nouvelle cible
			var hive_pos = Vector2(160, 560)
			var t_retour = create_tween()
			t_retour.tween_property(wo, "position", hive_pos, 1.5).set_ease(Tween.EASE_IN)
			await t_retour.finished
			continue
		
		var t_wait = create_tween()
		t_wait.tween_property(wo, "modulate", Color(0.8, 0.8, 0.2), 0.5)
		await _main._timer(1.0)
		
		var hive_pos = Vector2(160, 560)
		var t2 = create_tween()
		t2.tween_property(wo, "position", hive_pos, 3.0 * spd).set_ease(Tween.EASE_IN_OUT)
		await t2.finished
		if not is_instance_valid(wo): return
		
		wo.modulate = Color(0.8, 0.2, 0.2)
		var gain = GameManager.get_capacite_ouvriere() * nectar_fleur
		GameManager.honey += gain
		GameManager.honey_change.emit(GameManager.honey)
		GameManager.stats["miel_ouvrieres"] = GameManager.stats.get("miel_ouvrieres", 0) + gain
		await get_tree().create_timer(0.5).timeout

func spawn_blue_bee(target: Vector2):
	if GameManager.guerrieres_actives >= GameManager.get_guerriere_max(): return
	GameManager.guerrieres_actives += 1
	var wb = Sprite2D.new()
	var bt = load("res://Assets/Sprites/Bees/bee_worker.png")
	if bt: wb.texture = bt; wb.scale = Vector2(0.12, 0.12); wb.modulate = Color(0.3, 0.5, 1.5)
	wb.position = Vector2(640, 300); _main.add_child(wb)
	var t = create_tween()
	t.tween_property(wb, "position", target, 0.8).set_ease(Tween.EASE_OUT)
	t.tween_callback(func(): wb.queue_free(); GameManager.guerrieres_actives -= 1; if _main: _main._guerriere_en_vol = false)

func utiliser_skill(skill_id: String) -> bool:
	if not GameManager.utiliser_skill(skill_id): return false
	match skill_id:
		"cri_royal":
			_main._show_popup("👑 Cri Royal !")
		"ponte":
			var max_o = GameManager.get_max_ouvrieres()
			for i in range(min(5, max_o - GameManager.ouvrieres)):
				ajouter_ouvriere()
			GameManager.save()
		"essaim":
			_main._show_popup("🐝 Essaim !")
	return true

func retirer_ouvriere(wo):
	_ouvrieres.erase(wo)
	GameManager.ouvrieres -= 1
	if GameManager.ouvrieres < 0: GameManager.ouvrieres = 0
	GameManager.save()
	if not is_instance_valid(wo.node): return
	var t = create_tween()
	t.tween_property(wo.node, "modulate", Color(1, 0, 0, 0), 0.3)
	t.tween_callback(wo.node.queue_free)
