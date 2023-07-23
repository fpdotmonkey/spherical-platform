extends CharacterBody3D


@export var speed: float = 3.0
var center: Vector3 = Vector3.ZERO
var forward: GoDirection = GoDirection.NEUTRAL
var left: GoDirection = GoDirection.NEUTRAL
#@export var height: float = 10.5

#@export var my_basis = transform.basis
#@export var up: Vector3 = Vector3.ZERO
#@export var forward: Vector3 = Vector3.ZERO
#
@onready var velocity_debug = $velocity_thing

enum GoDirection {
	DRIVE,
	NEUTRAL,
	REVERSE
}


func new_gravity(gravity: Vector3):
	center = gravity
	
	
func face_gravity():
	var up = position - center
	var rotation_axis = transform.basis.y.cross(up).normalized()
	if rotation_axis == Vector3.ZERO:
		return
	var rotation_angle = transform.basis.y.signed_angle_to(up, rotation_axis)

	rotate(rotation_axis, rotation_angle)
	up_direction = transform.basis.y
	
	
func _input(event):
	if event.is_action_pressed("up", true):
		forward = GoDirection.DRIVE
	if event.is_action_pressed("left", true):
		left = GoDirection.DRIVE
	if event.is_action_pressed("down", true):
		forward = GoDirection.REVERSE
	if event.is_action_pressed("right", true):
		left = GoDirection.REVERSE
	if event.is_action_released("up", true) or event.is_action_released("down", true):
		forward = GoDirection.NEUTRAL
	if event.is_action_released("left", true) or event.is_action_released("right", true):
		left = GoDirection.NEUTRAL

	var z: float = 0.0
	var x: float = 0.0
	match forward:
		GoDirection.DRIVE:
			z = -1.0
		GoDirection.REVERSE:
			z = 1.0
		_:
			z = 0.0
	match left:
		GoDirection.DRIVE:
			x = -1.0
		GoDirection.REVERSE:
			x = 1.0
		_:
			x = 0.0
	velocity = speed * (transform.basis * Vector3(x, 0.0, z))


func _physics_process(delta):
	move_and_slide()
	face_gravity()
	apply_floor_snap()
	
	
func _process(delta):
	var v = velocity
	if is_on_floor():
		v = get_real_velocity()
	velocity_debug.set_position(transform.basis.inverse() * velocity)
