extends Node

class_name UpgradeCameraController

# Handles camera pan, zoom, and recenter for the upgrade tree viewport.
# No business logic — pure input-to-camera mapping.

var camera: Camera2D
var _default_pos := Vector2(120, 80)
var _min_zoom := Vector2(0.5, 0.5)
var _max_zoom := Vector2(1.5, 1.5)

func setup(cam: Camera2D):
	camera = cam

func recenter():
	camera.position = _default_pos
	camera.zoom = Vector2(1, 1)

func handle_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.zoom *= 1.1
			camera.zoom = camera.zoom.clamp(_min_zoom, _max_zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom /= 1.1
			camera.zoom = camera.zoom.clamp(_min_zoom, _max_zoom)
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		camera.position -= event.relative / camera.zoom
