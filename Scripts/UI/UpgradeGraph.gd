extends Node

class_name UpgradeGraph

# Reads Data/upgrades.json and builds UpgradeBranch instances.
# No UI logic beyond creating the branch hierarchy.

const DATA_PATH := "res://Data/upgrades.json"

func load_data() -> Dictionary:
	var file = FileAccess.open(DATA_PATH, FileAccess.READ)
	if not file: return {}
	var text = file.get_as_text()
	file.close()
	var json = JSON.new()
	if json.parse(text) == OK:
		return json.data
	return {}

func get_branch_defs() -> Array:
	var data = load_data()
	return data.get("branches", [])

func build_branches(parent: Node, buy_handler: Callable) -> Array:
	var branches := []
	var branch_defs = get_branch_defs()
	var x := 0.0
	
	for def in branch_defs:
		var branch = UpgradeBranch.create(def)
		branch.position = Vector2(x, 0)
		parent.add_child(branch)
		_connect_signals(branch, buy_handler)
		branches.append(branch)
		x += 350  # BRANCH_GAP_X
	
	return branches

func _connect_signals(branch: UpgradeBranch, handler: Callable):
	if branch._root_node:
		branch._root_node.clicked.connect(handler)
	for child in branch._child_nodes:
		child.clicked.connect(handler)
