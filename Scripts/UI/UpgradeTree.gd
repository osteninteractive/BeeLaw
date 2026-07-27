extends Control

signal ferme

var _cam: Camera2D
var _branches_container: Control
var _tooltip: Panel
var _feedback_rect: ColorRect

const NODE_SIZE := 96
const NODE_GAP_Y := 150
const BRANCH_GAP_X := 350
const LINE_COLOR := Color(0.35, 0.25, 0.15, 0.7)

func _ready():
	mouse_filter = MOUSE_FILTER_STOP
	anchor_right = 1.0; anchor_bottom = 1.0
	
	var bg = ColorRect.new(); bg.anchor_right = 1.0; bg.anchor_bottom = 1.0
	bg.color = Color(0.08, 0.05, 0.03, 0.97); add_child(bg)
	
	# Camera + SubViewport for smooth navigation
	var sv = SubViewport.new(); sv.name = "TreeViewport"
	sv.anchor_right = 1.0; sv.anchor_bottom = 1.0
	sv.transparent_bg = true; add_child(sv)
	
	_cam = Camera2D.new(); _cam.name = "TreeCamera"
	_cam.position = Vector2(0, 0); _cam.zoom = Vector2(1, 1)
	sv.add_child(_cam)
	_cam.make_current()
	
	_branches_container = Control.new(); _branches_container.name = "Branches"
	_branches_container.position = Vector2(80, 60)
	sv.add_child(_branches_container)
	
	_build_tree()
	
	# Controls overlay (fixed, not affected by camera)
	_build_overlay()
	
	# Feedback rect
	_feedback_rect = ColorRect.new(); _feedback_rect.anchor_right = 1.0; _feedback_rect.anchor_bottom = 1.0
	_feedback_rect.color = Color(0.2, 1, 0.2, 0); _feedback_rect.mouse_filter = MOUSE_FILTER_IGNORE
	_feedback_rect.visible = false; add_child(_feedback_rect)

func _build_tree():
	var x := 0.0
	for branch_name in GameManager.BRANCH_ORDER:
		var ids = _get_branch_nodes(branch_name)
		if ids.is_empty(): continue
		var branch = _create_branch(branch_name, ids, x)
		_branches_container.add_child(branch)
		x += BRANCH_GAP_X

func _get_branch_nodes(branch_name: String) -> Array:
	for root_id in GameManager.UPGRADE_IDS:
		var info = GameManager.UPGRADE_IDS[root_id]
		if info.get("branche") == branch_name and not info.has("parent"):
			var children := []
			for child_id in GameManager.UPGRADE_IDS:
				if GameManager.UPGRADE_IDS[child_id].get("parent") == root_id:
					children.append(child_id)
			return [root_id, children]
	return []

func _create_branch(name: String, data: Array, x: float) -> Control:
	var branch = Control.new(); branch.name = "Branch_" + name
	branch.position = Vector2(x, 0)
	
	var root_id = data[0]
	var children: Array = data[1]
	
	# Root node
	var root = _create_node(root_id, Vector2(0, 30))
	branch.add_child(root)
	
	# Branch lines to children
	var child_x := 0.0
	var total_width := max(1, children.size() - 1) * (NODE_SIZE + 60)
	for i in range(children.size()):
		var child = _create_node(children[i], Vector2(child_x - total_width * 0.5 + i * (NODE_SIZE + 60), NODE_GAP_Y))
		branch.add_child(child)
		# Draw connection from root to child
		branch.add_child(_make_line(Vector2(0, 30 + NODE_SIZE), child.position + Vector2(NODE_SIZE * 0.5, 0)))
	
	return branch

func _create_node(up_id: String, pos: Vector2) -> Control:
	var btn = Button.new()
	btn.name = "Node_" + up_id
	btn.position = pos
	btn.custom_minimum_size = Vector2(NODE_SIZE, NODE_SIZE)
	btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn.expand_icon = true
	
	# Style by state
	_refresh_node_style(btn, up_id)
	
	# Tooltip on hover
	btn.mouse_entered.connect(func(): _show_tooltip(up_id, btn))
	btn.mouse_exited.connect(_hide_tooltip)
	
	# Instant buy on click
	btn.pressed.connect(func(): _buy_instant(up_id))
	
	btn.set_meta("upgrade_id", up_id)
	return btn

func _refresh_node_style(btn: Button, up_id: String):
	var state = GameManager.get_upgrade_state(up_id)
	var niv = GameManager.get_upgrade_level(up_id)
	var max_niv = GameManager.get_upgrade_max_level(up_id)
	
	var info = GameManager.UPGRADE_IDS[up_id]
	var emoji = _branch_emoji(info.get("branche", ""))
	
	match state:
		"locked":
			btn.text = "🔒"; btn.disabled = true
			btn.add_theme_color_override("font_color", Color(0.3, 0.3, 0.3))
		"maxed":
			btn.text = emoji + "\nMAX"; btn.disabled = true
			btn.add_theme_color_override("font_color", Color(1, 0.6, 0.2))
		"upgradeable":
			btn.text = emoji + "\n" + str(niv) + "/" + str(max_niv); btn.disabled = false
			btn.add_theme_color_override("font_color", Color(0.3, 1, 0.3))
		"available", "purchased":
			btn.text = emoji + "\n" + str(niv) + "/" + str(max_niv); btn.disabled = false
			btn.add_theme_color_override("font_color", Color(1, 1, 0.8))
		_:
			btn.text = emoji + "\n" + str(niv) + "/" + str(max_niv); btn.disabled = false
	
	# Name label above
	btn.tooltip_text = info.get("nom", up_id)

func _branch_emoji(branch: String) -> String:
	match branch:
		"forager": return "🐝"
		"worker": return "🐜"
		"warrior": return "⚔"
	return "●"

func _make_line(from: Vector2, to: Vector2) -> Line2D:
	var line = Line2D.new()
	line.width = 4; line.default_color = LINE_COLOR
	var mid := Vector2(from.x, (from.y + to.y) * 0.5)
	line.points = [from, mid, Vector2(to.x, mid.y), to]
	return line

func _buy_instant(up_id: String):
	if GameManager.buy_upgrade(up_id):
		_animate_feedback()
		_refresh_all_nodes()
		_play_buy_sound()

func _animate_feedback():
	_feedback_rect.visible = true
	_feedback_rect.modulate.a = 0.3
	var tw = create_tween()
	tw.tween_property(_feedback_rect, "modulate:a", 0.0, 0.3)
	tw.tween_callback(func(): _feedback_rect.visible = false)

func _play_buy_sound():
	var s = load("res://Assets/Audio/bee_click.wav")
	if s:
		var p = AudioStreamPlayer2D.new(); p.stream = s; add_child(p); p.play(); p.finished.connect(p.queue_free)

func _refresh_all_nodes():
	for child in _branches_container.get_children():
		for node in child.get_children():
			if node is Button and node.has_meta("upgrade_id"):
				_refresh_node_style(node, node.get_meta("upgrade_id"))

func _show_tooltip(up_id: String, target: Button):
	if _tooltip: _tooltip.queue_free()
	_tooltip = Panel.new()
	_tooltip.name = "Tooltip"
	_tooltip.mouse_filter = MOUSE_FILTER_IGNORE
	
	var info = GameManager.UPGRADE_IDS[up_id]
	var niv = GameManager.get_upgrade_level(up_id)
	var max_niv = GameManager.get_upgrade_max_level(up_id)
	var cost = GameManager.get_upgrade_cost(up_id)
	var state = GameManager.get_upgrade_state(up_id)
	var desc = GameManager.get_upgrade_description(up_id)
	
	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 4)
	_tooltip.add_child(vb)
	
	var tl = Label.new(); tl.text = info.get("nom", up_id)
	tl.add_theme_font_size_override("font_size", 14); tl.add_theme_color_override("font_color", Color(1, 0.85, 0.5))
	vb.add_child(tl)
	
	var dl = Label.new(); dl.text = desc
	dl.add_theme_font_size_override("font_size", 11); dl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vb.add_child(dl)
	
	var ll = Label.new()
	if state == "maxed":
		ll.text = "MAX"; ll.add_theme_color_override("font_color", Color(1, 0.5, 0.2))
	elif state == "locked":
		ll.text = "🔒 " + GameManager.get_upgrade_block_reason(up_id); ll.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	else:
		ll.text = "Niv " + str(niv) + "/" + str(max_niv) + " | Coût: " + str(cost) + " miel"
	vb.add_child(ll)
	
	var style = StyleBoxFlat.new(); style.bg_color = Color(0.05, 0.03, 0.02, 0.95)
	style.corner_radius_top_left = 6; style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6; style.corner_radius_bottom_right = 6
	style.border_width_left = 1; style.border_width_top = 1; style.border_width_right = 1; style.border_width_bottom = 1
	style.border_color = Color(0.5, 0.4, 0.2, 0.6)
	_tooltip.add_theme_stylebox_override("panel", style)
	
	add_child(_tooltip)
	_tooltip.position = target.global_position + Vector2(NODE_SIZE + 10, -20)

func _hide_tooltip():
	if _tooltip: _tooltip.queue_free()

func _build_overlay():
	# Close button
	var close = Button.new(); close.text = "✕"; close.position = Vector2(1225, 10)
	close.custom_minimum_size = Vector2(40, 40)
	close.pressed.connect(func(): ferme.emit(); queue_free())
	add_child(close)
	
	# Recenter button
	var ctr = Button.new(); ctr.text = "⌂"; ctr.position = Vector2(1175, 10)
	ctr.custom_minimum_size = Vector2(40, 40)
	ctr.pressed.connect(func(): _cam.position = Vector2(0, 0); _cam.zoom = Vector2(1, 1))
	add_child(ctr)

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		_cam.zoom *= 1.1
		_cam.zoom = _cam.zoom.clamp(Vector2(0.5, 0.5), Vector2(1.5, 1.5))
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		_cam.zoom /= 1.1
		_cam.zoom = _cam.zoom.clamp(Vector2(0.5, 0.5), Vector2(1.5, 1.5))
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_cam.position -= event.relative / _cam.zoom
