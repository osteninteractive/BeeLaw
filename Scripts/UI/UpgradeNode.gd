extends Control

class_name UpgradeNode

const SIZE := 96

signal clicked(upgrade_id: String)

var _id: String
var _btn: Button

static func create(up_id: String, pos: Vector2) -> UpgradeNode:
	var node = UpgradeNode.new()
	node._id = up_id
	node.name = "Node_" + up_id
	node.position = pos
	node.custom_minimum_size = Vector2(SIZE, SIZE)
	
	node._btn = Button.new(); node._btn.custom_minimum_size = Vector2(SIZE, SIZE)
	node._btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER; node._btn.expand_icon = true
	node._btn.pressed.connect(func(): node.clicked.emit(up_id))
	node.add_child(node._btn)
	
	node.refresh()
	return node

func refresh():
	var state = GameManager.get_upgrade_state(_id)
	var info = GameManager.UPGRADE_IDS[_id]
	var niv = GameManager.get_upgrade_level(_id)
	var max_niv = GameManager.get_upgrade_max_level(_id)
	
	match info.get("branche"):
		"forager": _btn.text = "🐝"
		"worker": _btn.text = "🐜"
		"warrior": _btn.text = "⚔"
		_: _btn.text = "●"
	
	match state:
		"locked":
			_btn.text += "\n🔒"; _btn.disabled = true
			_btn.modulate = Color(0.3, 0.3, 0.3)
		"maxed":
			_btn.text += "\nMAX"; _btn.disabled = true
			_btn.modulate = Color(1, 0.6, 0.2, 0.8)
		"upgradeable":
			_btn.text += "\n" + str(niv) + "/" + str(max_niv); _btn.disabled = false
			_btn.modulate = Color(0.3, 1, 0.3, 1)
		"available", "purchased":
			_btn.text += "\n" + str(niv) + "/" + str(max_niv); _btn.disabled = false
			_btn.modulate = Color(1, 1, 0.8, 1)
		_:
			_btn.text += "\n" + str(niv) + "/" + str(max_niv)
			_btn.modulate = Color(1, 1, 1)
	
	_tooltip_text()

func _tooltip_text():
	var info = GameManager.UPGRADE_IDS[_id]
	var cost = GameManager.get_upgrade_cost(_id)
	var state = GameManager.get_upgrade_state(_id)
	var niv = GameManager.get_upgrade_level(_id)
	
	var txt = info.get("nom", _id) + "\n" + GameManager.get_upgrade_description(_id) + "\n"
	if state == "maxed": txt += "MAX"
	elif state == "locked": txt += "🔒 " + GameManager.get_upgrade_block_reason(_id)
	else: txt += "Niv " + str(niv) + "/" + str(GameManager.get_upgrade_max_level(_id)) + " | " + str(cost) + " miel"
	_btn.tooltip_text = txt
