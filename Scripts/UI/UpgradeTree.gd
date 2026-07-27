extends Control

class_name UpgradeTree

# Orchestrator: builds the upgrade tree scene, coordinates components.
# Responsibilities: scene setup, component wiring, navigation events.
# Business logic → GameManager. Layout → UpgradeGraph. Camera → UpgradeCameraController.

signal ferme

var _cam_controller: UpgradeCameraController
var _graph: UpgradeGraph
var _branches: Array = []
var _feedback_rect: ColorRect

func _ready():
	mouse_filter = MOUSE_FILTER_STOP
	anchor_right = 1.0; anchor_bottom = 1.0
	
	# Background
	var bg = ColorRect.new(); bg.anchor_right = 1.0; bg.anchor_bottom = 1.0
	bg.color = Color(0.08, 0.05, 0.03, 0.97); add_child(bg)
	
	# Viewport + Camera
	var sv = SubViewport.new(); sv.anchor_right = 1.0; sv.anchor_bottom = 1.0
	sv.transparent_bg = true; add_child(sv)
	
	var cam = Camera2D.new(); sv.add_child(cam); cam.make_current()
	_cam_controller = UpgradeCameraController.new(); _cam_controller.setup(cam)
	
	# Graph: reads data, creates branches
	_graph = UpgradeGraph.new()
	_branches = _graph.build_branches(sv, func(id): _on_node_click(id))
	
	# Feedback overlay
	_feedback_rect = ColorRect.new(); _feedback_rect.anchor_right = 1.0; _feedback_rect.anchor_bottom = 1.0
	_feedback_rect.color = Color(0.2, 1, 0.2, 0); _feedback_rect.mouse_filter = MOUSE_FILTER_IGNORE; add_child(_feedback_rect)
	
	# Fixed overlay (not affected by camera)
	_build_overlay()

# --- Input routing ---
func _input(event: InputEvent):
	_cam_controller.handle_input(event)

# --- Buy handler ---
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

# --- Overlay (fixed position, outside camera) ---
func _build_overlay():
	var close = Button.new(); close.text = "✕"; close.position = Vector2(1225, 10)
	close.custom_minimum_size = Vector2(40, 40)
	close.pressed.connect(func(): ferme.emit(); queue_free()); add_child(close)
	
	var ctr = Button.new(); ctr.text = "⌂"; ctr.position = Vector2(1175, 10)
	ctr.custom_minimum_size = Vector2(40, 40)
	ctr.pressed.connect(_cam_controller.recenter); add_child(ctr)
