extends Panel

signal ferme

var _nodes = {}

const CATEGORIES = {
	"🐝 Abeilles": {
		"icone": "🐝",
		"items": [
			{"id": "max", "icone": "🐝", "nom": "Ouvri\u00e8re", "desc": "Ajoute une ouvri\u00e8re automatique", "prix": 250, "max": 5},
			{"id": "vitesse_ouvriere", "icone": "\u26a1", "nom": "Vitesse ouvri\u00e8re", "desc": "Les ouvri\u00e8res volent plus vite", "prix": 100, "max": 5},
			{"id": "capacite_ouvriere", "icone": "\ud83c\udf3e", "nom": "Capacit\u00e9", "desc": "Chaque ouvri\u00e8re rapporte plus", "prix": 100, "max": 5},
		]
	},
	"\ud83c\udf6d R\u00e9colte": {
		"icone": "\ud83c\udf6d",
		"items": [
			{"id": "clic", "icone": "\u2611", "nom": "Butineuse", "desc": "Puissance de clic augment\u00e9e", "prix": 10, "max": 5},
			{"id": "vitesse_click", "icone": "\ud83d\udca8", "nom": "Vitesse de clic", "desc": "L'abeille de clic vole plus vite", "prix": 10, "max": 5},
		]
	},
	"\ud83d\udc94 D\u00e9fense": {
		"icone": "\u2694\ufe0f",
		"items": [
			{"id": "guerriere", "icone": "\U0001f535", "nom": "Guerri\u00e8re", "desc": "D\u00e9ploie une abeille guerri\u00e8re suppl\u00e9mentaire", "prix": 500, "max": 99},
			{"id": "recompense_frelon", "icone": "\ud83d\udc1d", "nom": "Prime frelon", "desc": "+5 honey par frelon tu\u00e9", "prix": 2, "max": 10, "prestige": true},
			{"id": "recompense_ours", "icone": "\ud83d\udc3b", "nom": "Prime ours", "desc": "+25 honey par ours tu\u00e9", "prix": 3, "max": 10, "prestige": true},
		]
	},
	"\u2764\ufe0f Reine": {
		"icone": "\ud83d\udc1d",
		"items": [
			{"id": "boost_capacite", "icone": "\ud83d\udcaa", "nom": "Boost capacit\u00e9", "desc": "+1 capacit\u00e9 ouvri\u00e8re permanent", "prix": 2, "max": 10, "prestige": true},
			{"id": "guerriere_slots", "icone": "\ud83d\udee1\ufe0f", "nom": "Guerri\u00e8re +", "desc": "+1 guerri\u00e8re simultan\u00e9e", "prix": 5, "max": 4, "prestige": true},
		]
	},
	"\ud83d\udcb0 \u00c9conomie": {
		"icone": "\ud83d\udcb0",
		"items": [
			{"id": "boost_clic", "icone": "\ud83d\udcb0", "nom": "Boost Clic", "desc": "+1/clic permanent", "prix": 2, "max": 10, "prestige": true},
			{"id": "miel_depart", "icone": "\ud83c\udf6f", "nom": "Miel d\u00e9part", "desc": "+50 honey au d\u00e9part", "prix": 1, "max": 20, "prestige": true},
			# {"id": "ouvriere_depart", "icone": "\ud83d\udca1", "nom": "Ouvri\u00e8re d\u00e9part", "desc": "+1 ouvri\u00e8re au d\u00e9part", "prix": 3, "max": 10, "prestige": true},
		]
	},
	"\u2699\ufe0f Prestige": {
		"icone": "\u2699\ufe0f",
		"items": [
			{"id": "sante_plus", "icone": "\u2764\ufe0f", "nom": "Ruche +", "desc": "+10% sant\u00e9 ruche", "prix": 5, "max": 5, "prestige": true},
			{"id": "ouvriere_slots", "icone": "\ud83d\udee0\ufe0f", "nom": "Slot ouvri\u00e8re", "desc": "+1 max ouvri\u00e8re", "prix": 1, "max": 10, "prestige": true, "double": true},
		]
	},
}

func _init():
	process_mode = Node.PROCESS_MODE_ALWAYS
	anchor_right = 1.0; anchor_bottom = 1.0

func _ready():
	_resize()
	if not get_viewport().size_changed.is_connected(_resize):
		get_viewport().size_changed.connect(_resize)
	
	# Fond sombre
	var bg = Panel.new()
	bg.anchor_right = 1.0; bg.anchor_bottom = 1.0
	var obs = StyleBoxFlat.new(); obs.bg_color = Color(0.05, 0.04, 0.02, 0.92)
	bg.add_theme_stylebox_override("panel", obs)
	add_child(bg)
	
	# Titre + fermer
	var top = HBoxContainer.new(); top.position = Vector2(480, 10); add_child(top)
	var tl = Label.new(); tl.text = "⬆ Am\u00e9liorations"; tl.add_theme_font_size_override("font_size", 20)
	tl.add_theme_color_override("font_color", Color(0.9, 0.8, 0.2)); top.add_child(tl)
	var bf = Button.new(); bf.text = "X"; bf.pressed.connect(_on_fermer); top.add_child(bf)
	
	# Categories en grille centree
	var center_x = 200
	var start_y = 70
	var cat_positions = []
	var i = 0
	for cat_name in CATEGORIES.keys():
		var cat = CATEGORIES[cat_name]
		var col = i % 3
		var row = floor(i / 3)
		var px = center_x + col * 320
		var py = start_y + row * 200
		cat_positions.append({"name": cat_name, "x": px, "y": py, "cat": cat})
		i += 1
	
	for cp in cat_positions:
		_draw_category(cp.name, cp.cat, cp.x, cp.y)

func _draw_category(name: String, cat: Dictionary, x: int, y: int):
	# Titre de categorie
	var tl = Label.new(); tl.text = cat.icone + " " + name
	tl.position = Vector2(x + 20, y - 30)
	tl.add_theme_font_size_override("font_size", 13)
	tl.add_theme_color_override("font_color", Color(0.8, 0.7, 0.3))
	add_child(tl)
	
	# Items dans la categorie
	var item_x = x + 10
	for item in cat.items:
		var node = preload("res://Scripts/UI/UpgradeNode.gd").new()
		node.setup(
			item.id, name, item.icone, item.nom, item.desc,
			item.prix, item.max, item.get("double", false),
			item.get("prestige", false)
		)
		node.position = Vector2(item_x, y)
		node.achete.connect(_on_achete)
		add_child(node)
		_nodes[item.id] = node
		item_x += 120

func _on_achete(id: String):
	GameManager.honey_change.emit(GameManager.honey)
	GameManager.pollen_change.emit(GameManager.pollen)

func _on_fermer():
	ferme.emit()
	queue_free()

func _resize():
	position = Vector2.ZERO
	size = get_viewport_rect().size
