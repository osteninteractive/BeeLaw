extends Node

signal fleur_morte(index)
signal fleur_recoltee(index, gain)

var _fleure_areas = []
var _fleurs_hp = []
var _fleurs_data = []
var _fleurs_max_hp = []
var _main_parent: Node2D
var _biome_actuel = 0

func _ready():
	GameManager.biome_change.connect(_on_biome_change)

func _poids_from_hp(hp: int) -> float:
	return 100.0 / hp

func _choisir_fleur_pondere(biome_fleurs: Array):
	var poids = []
	var total = 0.0
	for f in biome_fleurs:
		var hp = f[7]
		var p = _poids_from_hp(hp)
		poids.append(p)
		total += p
	var r = randf() * total
	var cumul = 0.0
	for i in biome_fleurs.size():
		cumul += poids[i]
		if r <= cumul:
			return biome_fleurs[i]
	return biome_fleurs[0]

func _position_fleur():
	for _tentative in 20:
		var x = 260 + randi() % 780
		var y = 480 + randi() % 200
		if x > 100 and x < 220 and y > 500 and y < 600: continue
		var trop_proche = false
		for area in _fleure_areas:
			if is_instance_valid(area) and area.position.distance_to(Vector2(x, y)) < 80:
				trop_proche = true; break
		if not trop_proche:
			return Vector2(x, y)
	return Vector2(400 + randi() % 400, 520 + randi() % 100)

func spawner(main_parent: Node2D, biome: int):
	_fleure_areas.clear(); _fleurs_hp.clear(); _fleurs_data.clear()
	_fleurs_max_hp.clear()
	_main_parent = main_parent
	_biome_actuel = biome
	var biome_fleurs = []
	for f in GameManager.FLEURS_DATA:
		if f[2] <= biome: biome_fleurs.append(f)
	if biome_fleurs.is_empty(): biome_fleurs = [GameManager.FLEURS_DATA[0]]
	for i in 7:
		_creer_fleur(biome_fleurs)

func _creer_fleur(biome_fleurs: Array, idx = -1):
	var fd = _choisir_fleur_pondere(biome_fleurs)
	var max_hp = int(fd[7])
	var sprite_id = fd[8]
	
	var area = Area2D.new()
	var pos = _position_fleur()
	area.position = pos
	var col = CollisionShape2D.new()
	var rect = RectangleShape2D.new(); rect.size = Vector2(40, 40)
	col.shape = rect; area.add_child(col)
	
	var spr = Sprite2D.new(); spr.name = "Sprite2D"
	var ft = load("res://Assets/Sprites/Flowers/" + sprite_id + ".png")
	if ft: spr.texture = ft; spr.scale = Vector2(1.2, 1.2)
	area.add_child(spr)
	
	# Barre de vie
	var hp_bar = ProgressBar.new()
	hp_bar.name = "HPBar"
	hp_bar.min_value = 0; hp_bar.max_value = max_hp; hp_bar.value = max_hp
	hp_bar.custom_minimum_size = Vector2(60, 6); hp_bar.position = Vector2(-30, -70)
	hp_bar.show_percentage = false; hp_bar.visible = false
	var pbg = StyleBoxFlat.new(); pbg.bg_color = Color(0.3, 0.3, 0.3, 0.6)
	pbg.corner_radius_top_left = 2; pbg.corner_radius_top_right = 2
	pbg.corner_radius_bottom_left = 2; pbg.corner_radius_bottom_right = 2
	hp_bar.add_theme_stylebox_override("background", pbg)
	var pfl = StyleBoxFlat.new(); pfl.bg_color = Color(0.2, 0.8, 0.2)
	pfl.corner_radius_top_left = 2; pfl.corner_radius_top_right = 2
	pfl.corner_radius_bottom_left = 2; pfl.corner_radius_bottom_right = 2
	hp_bar.add_theme_stylebox_override("fill", pfl)
	area.add_child(hp_bar)
	
	_main_parent.add_child(area)
	
	if idx >= 0 and idx < _fleure_areas.size():
		_fleure_areas[idx].queue_free()
		_fleure_areas[idx] = area
		_fleurs_data[idx] = fd
		_fleurs_hp[idx] = max_hp
		_fleurs_max_hp[idx] = max_hp
	else:
		_fleure_areas.append(area)
		_fleurs_data.append(fd)
		_fleurs_hp.append(max_hp)
		_fleurs_max_hp.append(max_hp)

func recolter(idx: int) -> Dictionary:
	if idx < 0 or idx >= _fleurs_hp.size() or _fleurs_hp[idx] <= 0: return {"nectar": 0, "pollen": 0}
	var fd = _fleurs_data[idx]
	var gain = fd[3]
	_fleurs_hp[idx] -= 1
	
	# Mise a jour visuelle
	if idx < _fleure_areas.size() and is_instance_valid(_fleure_areas[idx]):
		var area = _fleure_areas[idx]
		# Barre de vie
		var hp_bar = area.get_node_or_null("HPBar")
		if hp_bar:
			hp_bar.value = _fleurs_hp[idx]
			hp_bar.visible = _fleurs_hp[idx] < _fleurs_max_hp[idx]
		# Opacite progressive
		var spr = area.get_node_or_null("Sprite2D")
		if spr:
			var ratio = float(_fleurs_hp[idx]) / float(_fleurs_max_hp[idx])
			spr.modulate.a = 0.35 + ratio * 0.65
	
	if _fleurs_hp[idx] <= 0:
		_fleurs_hp[idx] = 0
		if idx < _fleure_areas.size() and is_instance_valid(_fleure_areas[idx]):
			var area = _fleure_areas[idx]
			var spr = area.get_node_or_null("Sprite2D")
			if spr: spr.visible = false
		fleur_morte.emit(idx)
		var temps_repousse = float(fd[6])
		get_tree().create_timer(temps_repousse).timeout.connect(_regrow.bind(idx))
	
	fleur_recoltee.emit(idx, gain)
	return {"nectar": gain, "pollen": fd[9] if fd.size() > 9 else gain}

func _regrow(idx: int):
	if idx >= _fleurs_hp.size(): return
	var biome_fleurs = []
	for f in GameManager.FLEURS_DATA:
		if f[2] <= _biome_actuel: biome_fleurs.append(f)
	if biome_fleurs.is_empty(): biome_fleurs = [GameManager.FLEURS_DATA[0]]
	_creer_fleur(biome_fleurs, idx)

func get_vivante() -> int:
	if _fleure_areas.is_empty(): return -1
	var start = randi() % _fleure_areas.size()
	for i in _fleure_areas.size():
		var idx = (start + i) % _fleure_areas.size()
		if idx < _fleurs_hp.size() and _fleurs_hp[idx] > 0:
			return idx
	return -1

func get_data(idx: int):
	if idx < 0 or idx >= _fleurs_data.size(): return null
	return _fleurs_data[idx]

func get_position(idx: int) -> Vector2:
	if idx < 0 or idx >= _fleure_areas.size(): return Vector2.ZERO
	return _fleure_areas[idx].position

func _on_biome_change(biome_id: int):
	_biome_actuel = biome_id