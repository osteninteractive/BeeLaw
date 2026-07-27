extends Control

class_name UpgradeTree

signal ferme

const BRANCH_GAP_X := 350
const BRANCH_DATA = [
	{"id": "forager", "root_id": "buy_forager", "children": ["forager_speed", "forager_capacity"]},
	{"id": "worker", "root_id": "buy_worker", "children": ["worker_speed", "worker_capacity"]},
	{"id": "warrior", "root_id": "buy_warrior", "children": ["warrior_speed", "warrior_damage"]},
]

var _cam: Camera2D
var _branches: Array = []
var _feedback_rect: ColorRect

func _ready():
	mouse_filter = MOUSE_FILTER_STOP
	anchor_right = 1.0; anchor_bottom = 1.0
	
	var bg = ColorRect.new(); bg.anchor_right = 1.0; bg.anchor_bottom = 1.0
	bg.color = Color(0.08, 0.05, 0.03, 0.97); add_child(bg)
	
	# SubViewport + Camera2D
	var sv = SubViewport.new(); sv.anchor_right = 1.0; sv.anchor_bottom = 1.0
	sv.transparent_bg = true; add_child(sv)
	
	_cam = Camera2D.new(); _cam.position = Vector2(120, 80); _cam.zoom = Vector2(1, 1)
	sv.add_child(_cam); _cam.make_current()
	
	# Build all branches from data
	var x := 0.0
	for data in BRANCH_DATA:
		var branch = UpgradeBranch.create(data)
		branch.position = Vector2(x, 0); sv.add_child(branch)
		# Connect click signals
		_connect_branch_signals(branch)
		_branches.append(branch)
		x += BRANCH_GAP_X
	
	# Feedback overlay
	_feedback_rect = ColorRect.new(); _feedback_rect.anchor_right = 1.0; _feedback_rect.anchor_bottom = 1.0
	_feedback_rect.color = Color(0.2, 1, 0.2, 0); _feedback_rect.mouse_filter = MOUSE_FILTER_IGNORE; add_child(_feedback_rect)
	
	_build_overlay()

func _connect_branch_signals(branch: UpgradeBranch):
	if branch._root_node:
		branch._root_node.clicked.connect(_on_node_click)
	for child in branch._child_nodes:
		child.clicked.connect(_on_node_click)

func _on_node_click(up_id: String):
	if GameManager.buy_upgrade(up_id):
		_animate_feedback()
		_refresh_all()
		_play_sound()

func _refresh_all():
	for branch in _branches:
		branch.refresh()

func _animate_feedback():
	_feedback_rect.modulate.a = 0.3
	var tw = create_tween(); tw.tween_property(_feedback_rect, "modulate:a", 0.0, 0.3)

func _play_sound():
	var s = load("res://Assets/Audio/bee_click.wav")
	if s: var p = AudioStreamPlayer2D.new(); p.stream = s; add_child(p); p.play(); p.finished.connect(p.queue_free)

func _build_overlay():
	var close = Button.new(); close.text = "✕"; close.position = Vector2(1225, 10)
	close.custom_minimum_size = Vector2(40, 40)
	close.pressed.connect(func(): ferme.emit(); queue_free()); add_child(close)
	
	var ctr = Button.new(); ctr.text = "⌂"; ctr.position = Vector2(1175, 10)
	ctr.custom_minimum_size = Vector2(40, 40)
	ctr.pressed.connect(func(): _cam.position = Vector2(120, 80); _cam.zoom = Vector2(1, 1)); add_child(ctr)

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		_cam.zoom *= 1.1; _cam.zoom = _cam.zoom.clamp(Vector2(0.5, 0.5), Vector2(1.5, 1.5))
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		_cam.zoom /= 1.1; _cam.zoom = _cam.zoom.clamp(Vector2(0.5, 0.5), Vector2(1.5, 1.5))
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_cam.position -= event.relative / _cam.zoom
