extends Control

class_name UpgradeBranch

const NODE_SIZE := 96
const NODE_GAP_Y := 150

var _root_node: UpgradeNode
var _child_nodes: Array = []
var _connections: Array = []

static func create(branch_data: Dictionary) -> UpgradeBranch:
	var branch = UpgradeBranch.new()
	branch.name = "Branch_" + branch_data["id"]
	
	# Root node
	branch._root_node = UpgradeNode.create(branch_data["root_id"], Vector2(0, 30))
	branch.add_child(branch._root_node)
	
	# Children nodes
	var children = branch_data.get("children", [])
	var total_width = max(1, children.size() - 1) * (NODE_SIZE + 40)
	for i in range(children.size()):
		var child = UpgradeNode.create(children[i], Vector2(i * (NODE_SIZE + 40) - total_width * 0.5, NODE_GAP_Y))
		branch._child_nodes.append(child)
		branch.add_child(child)
		
		# Connection line
		var conn = UpgradeConnection.create(branch._root_node.position + Vector2(NODE_SIZE * 0.5, NODE_SIZE),
			child.position + Vector2(NODE_SIZE * 0.5, 0))
		branch._connections.append(conn)
		branch.add_child(conn)
		branch.move_child(conn, 0)
	
	return branch

func refresh():
	_root_node.refresh()
	for child in _child_nodes:
		child.refresh()
