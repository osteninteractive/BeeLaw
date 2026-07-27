extends Control

signal ferme

var _cam_offset := Vector2.ZERO
var _cam_zoom := 1.0
var _dragging := false
var _drag_start := Vector2.ZERO
var _cam_start := Vector2.ZERO
var _confirm_panel: Panel
var _current_buy_id := ""

func _ready():
	anchor_right = 1.0; anchor_bottom = 1.0
	
	# Fond
	var bg = ColorRect.new(); bg.anchor_right = 1.0; bg.anchor_bottom = 1.0
	bg.color = Color(0.1, 0.07, 0.04, 0.95); add_child(bg)
	
	# Bouton fermer
	var close = Button.new(); close.text = "✕"; close.position = Vector2(1220, 10)
	close.custom_minimum_size = Vector2(40, 40)
	close.pressed.connect(func(): ferme.emit(); queue_free())
	close.add_theme_font_size_override("font_size", 20)
	add_child(close)
	
	# Bouton recentrer
	var ctr = Button.new(); ctr.text = "⌂"; ctr.position = Vector2(1170, 10)
	ctr.custom_minimum_size = Vector2(40, 40)
	ctr.pressed.connect(_recenter)
	ctr.add_theme_font_size_override("font_size", 18)
	add_child(ctr)
	
	# Conteneur des branches
	var container = Control.new(); container.name = "TreeContainer"
	container.position = Vector2(100, 80); add_child(container)
	
	_draw_branches(container)
	_recenter()

func _draw_branches(container: Control):
	var x := 40.0
	for branch_name in GameManager.BRANCH_ORDER:
		var branch_ids = _get_branch_nodes(branch_name)
		var y := 50.0
		var root_node: Control = null
		var first := true
		for up_id in branch_ids:
			var node = _create_upgrade_node(up_id, x, y)
			container.add_child(node)
			y += 150
			if first:
				root_node = node
				first = false
			else:
				_draw_connection(container, root_node, node)
		x += 380

func _get_branch_nodes(branch_name: String) -> Array:
	for id in GameManager.UPGRADE_IDS:
		var info = GameManager.UPGRADE_IDS[id]
		if info.get("branche") == branch_name and not info.has("parent"):
			var result = [id]
			# Find children
			for child_id in GameManager.UPGRADE_IDS:
				if GameManager.UPGRADE_IDS[child_id].get("parent") == id:
					result.append(child_id)
			return result
	return []

func _create_upgrade_node(up_id: String, x: float, y: float) -> Control:
	var card = Panel.new()
	card.name = "Node_" + up_id
	card.position = Vector2(x, y)
	card.custom_minimum_size = Vector2(300, 120)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.1, 0.06, 0.95)
	style.corner_radius_top_left = 8; style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8; style.corner_radius_bottom_right = 8
	style.border_width_left = 2; style.border_width_top = 2
	style.border_width_right = 2; style.border_width_bottom = 2
	card.add_theme_stylebox_override("panel", style)
	
	var vb = VBoxContainer.new()
	vb.anchor_right = 1.0; vb.anchor_bottom = 1.0
	vb.add_theme_constant_override("separation", 4)
	card.add_child(vb)
	
	# Title
	var title = Label.new(); title.text = GameManager.UPGRADE_IDS[up_id]["nom"]
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(1, 0.9, 0.6))
	vb.add_child(title)
	
	# Level
	var lvl_label = Label.new(); lvl_label.name = "Level"
	vb.add_child(lvl_label)
	
	# Cost button
	var btn = Button.new(); btn.name = "BuyBtn"
	btn.custom_minimum_size = Vector2(280, 32)
	btn.add_theme_font_size_override("font_size", 12)
	btn.pressed.connect(func(): _on_buy_click(up_id))
	vb.add_child(btn)
	
	# Block reason
	var reason = Label.new(); reason.name = "Reason"
	reason.add_theme_font_size_override("font_size", 10)
	reason.add_theme_color_override("font_color", Color(1, 0.4, 0.4))
	reason.visible = false
	vb.add_child(reason)
	
	# Store metadata
	card.set_meta("upgrade_id", up_id)
	
	_refresh_node(card)
	return card

func _refresh_node(card: Control):
	var up_id = card.get_meta("upgrade_id")
	var state = GameManager.get_upgrade_state(up_id)
	var niv = GameManager.get_upgrade_level(up_id)
	var max_niv = GameManager.get_upgrade_max_level(up_id)
	var cost = GameManager.get_upgrade_cost(up_id)
	
	var lvl = card.get_node_or_null("VBoxContainer/Level")
	if lvl: lvl.text = "Niv " + str(niv) + " / " + str(max_niv)
	
	var btn = card.get_node_or_null("VBoxContainer/BuyBtn")
	if btn:
		match state:
			"maxed":
				btn.text = "MAX"; btn.disabled = true
				btn.add_theme_color_override("font_color", Color(1, 0.5, 0.2))
			"locked":
				btn.text = "🔒 Verrouillé"; btn.disabled = true
			"upgradeable":
				btn.text = "Améliorer — " + str(cost) + " miel"; btn.disabled = false
			"available":
				btn.text = "Acheter — " + str(cost) + " miel"; btn.disabled = false
			"purchased":
				btn.text = "Niv " + str(niv) + " — " + str(cost) + " miel"; btn.disabled = false
			_:
				btn.text = "Améliorer — " + str(cost) + " miel"; btn.disabled = false
	
	var reason = card.get_node_or_null("VBoxContainer/Reason")
	if reason:
		var block = GameManager.get_upgrade_block_reason(up_id)
		reason.text = block if block != "" and state in ["locked", "maxed"] else ""
		reason.visible = block != "" and state in ["locked", "maxed"]
	
	# Border color by state
	var style = card.get_theme_stylebox("panel", "Panel") as StyleBoxFlat
	if style:
		match state:
			"upgradeable": style.border_color = Color(0.2, 1, 0.2, 0.8)
			"maxed": style.border_color = Color(1, 0.5, 0.2, 0.8)
			"locked": style.border_color = Color(0.3, 0.3, 0.3, 0.5)
			_: style.border_color = Color(0.6, 0.5, 0.3, 0.6)

func _draw_connection(container: Control, parent: Control, child: Control):
	var line = Line2D.new(); line.name = "Connection"
	line.width = 3
	line.default_color = Color(0.6, 0.5, 0.3, 0.7)
	var pp = parent.position + Vector2(150, 120)
	var cp = child.position + Vector2(150, 0)
	line.points = [pp, Vector2(pp.x, cp.y), cp]
	container.add_child(line)
	container.move_child(line, 0)  # behind nodes

func _on_buy_click(up_id: String):
	if _confirm_panel:
		_confirm_panel.queue_free()
	_current_buy_id = up_id
	
	var state = GameManager.get_upgrade_state(up_id)
	if state in ["locked", "maxed"]: return
	
	# Confirmation panel
	_confirm_panel = Panel.new()
	_confirm_panel.position = Vector2(400, 280)
	_confirm_panel.custom_minimum_size = Vector2(400, 200)
	var cstyle = StyleBoxFlat.new(); cstyle.bg_color = Color(0.08, 0.05, 0.03, 0.98)
	cstyle.corner_radius_top_left = 10; cstyle.corner_radius_top_right = 10
	cstyle.corner_radius_bottom_left = 10; cstyle.corner_radius_bottom_right = 10
	_confirm_panel.add_theme_stylebox_override("panel", cstyle)
	add_child(_confirm_panel)
	
	var cvb = VBoxContainer.new(); cvb.anchor_right = 1.0; cvb.anchor_bottom = 1.0
	cvb.add_theme_constant_override("separation", 10)
	_confirm_panel.add_child(cvb)
	
	var info = GameManager.UPGRADE_IDS[up_id]
	var niv = GameManager.get_upgrade_level(up_id)
	var cost = GameManager.get_upgrade_cost(up_id)
	var desc = GameManager.get_upgrade_description(up_id)
	
	var tl = Label.new(); tl.text = info["nom"] + " ?"; tl.add_theme_font_size_override("font_size", 18)
	tl.add_theme_color_override("font_color", Color(1, 0.9, 0.6)); cvb.add_child(tl)
	
	var dl = Label.new(); dl.text = desc; dl.add_theme_font_size_override("font_size", 12)
	dl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8)); cvb.add_child(dl)
	
	var ll = Label.new(); ll.text = "Niv " + str(niv) + " → " + str(niv + 1) + " | Coût: " + str(cost) + " miel"
	ll.add_theme_font_size_override("font_size", 14); cvb.add_child(ll)
	
	var hb = HBoxContainer.new(); hb.add_theme_constant_override("separation", 20); cvb.add_child(hb)
	
	var cancel = Button.new(); cancel.text = "Annuler"; cancel.custom_minimum_size = Vector2(150, 40)
	cancel.pressed.connect(func(): _confirm_panel.queue_free(); _confirm_panel = null)
	hb.add_child(cancel)
	
	var confirm = Button.new(); confirm.text = "Confirmer"; confirm.custom_minimum_size = Vector2(150, 40)
	confirm.pressed.connect(func(): _execute_buy(up_id))
	hb.add_child(confirm)

func _execute_buy(up_id: String):
	if GameManager.buy_upgrade(up_id):
		_play_feedback()
		_refresh_all()
	if _confirm_panel:
		_confirm_panel.queue_free()
		_confirm_panel = null

func _play_feedback():
	var flash = ColorRect.new(); flash.anchor_right = 1.0; flash.anchor_bottom = 1.0
	flash.color = Color(0.2, 1, 0.2, 0.3); flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flash)
	var tw = create_tween(); tw.tween_property(flash, "modulate:a", 0.0, 0.3)
	tw.tween_callback(flash.queue_free)

func _refresh_all():
	for child in get_tree().get_nodes_in_group("upgrade_tree_nodes"):
		_refresh_node(child)
	# Also refresh direct children
	for child in get_children():
		if child is Panel and child.has_meta("upgrade_id"):
			_refresh_node(child)
		elif child.has_node("VBoxContainer"):
			for grand in child.get_children():
				if grand is Panel and grand.has_meta("upgrade_id"):
					_refresh_node(grand)

func _recenter():
	_cam_offset = Vector2(-50, -40)
	_cam_zoom = 1.0

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_cam_zoom = clamp(_cam_zoom * 1.1, 0.5, 1.5)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_cam_zoom = clamp(_cam_zoom / 1.1, 0.5, 1.5)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_dragging = true; _drag_start = event.position; _cam_start = _cam_offset
			else:
				_dragging = false
	elif event is InputEventMouseMotion and _dragging:
		_cam_offset = _cam_start + (event.position - _drag_start) / _cam_zoom
	
	var container = get_node_or_null("TreeContainer")
	if container:
		container.position = _cam_offset
		container.scale = Vector2(_cam_zoom, _cam_zoom)
