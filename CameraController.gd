extends Node3D


@onready var camera_rot: Node3D = $CameraRot
var control_enabled: bool = true

const camera_mouse_rotation_speed := 0.001
const camera_x_rot_min := deg_to_rad(-89.9)
const camera_x_rot_max := deg_to_rad(20)


func rotate_camera(move):
	rotate_y(-move.x)
	# After relative transforms, camera needs to be renormalized.
	orthonormalize()
	camera_rot.rotation.x = clamp(camera_rot.rotation.x + move.y, camera_x_rot_min, camera_x_rot_max)


func toggle_mouse_mode():
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		control_enabled = true
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		control_enabled = false


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	if event is InputEventMouseMotion and control_enabled:
		var camera_speed_this_frame = camera_mouse_rotation_speed
		rotate_camera(event.relative * camera_speed_this_frame)
	elif event.is_action_pressed("pause"):
		toggle_mouse_mode()
