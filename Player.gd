extends CharacterBody3D


@export var speed: float = 3.0
@export var jump_launch: float = 6.0
@export var gravity: float = 10.0

var center: Vector3 = Vector3.ZERO
var forward: GoDirection = GoDirection.NEUTRAL
var left: GoDirection = GoDirection.NEUTRAL
var jump_state: JumpState = JumpState.NOT
var jump_speed: float = 0.0

var input_velocity: Vector3 = Vector3.ZERO

@onready var velocity_debug = $velocity_thing
@onready var camera = $CameraBase

enum GoDirection {
	NEUTRAL,
	DRIVE,
	REVERSE
}

enum JumpState {
	NOT,
	PREPARING,
	JUMPING
}


func new_center(new: Vector3):
	center = new
	
	
func update_gravity():
	var up = position - center
	var rotation_axis = transform.basis.y.cross(up).normalized()
	if rotation_axis == Vector3.ZERO:
		return
	var rotation_angle = transform.basis.y.signed_angle_to(up, rotation_axis)

	rotate(rotation_axis, rotation_angle)
	up_direction = transform.basis.y
	
	
func _input(event):
	if event.is_action_pressed("up"):
		forward = GoDirection.DRIVE
	elif event.is_action_pressed("left"):
		left = GoDirection.DRIVE
	elif event.is_action_pressed("down"):
		forward = GoDirection.REVERSE
	elif event.is_action_pressed("right"):
		left = GoDirection.REVERSE
	elif event.is_action_pressed("jump"):
		if jump_state != JumpState.JUMPING:
			jump_state = JumpState.PREPARING
	elif event.is_action_released("up") or event.is_action_released("down"):
		forward = GoDirection.NEUTRAL
	elif event.is_action_released("left") or event.is_action_released("right"):
		left = GoDirection.NEUTRAL
	else:
		return

	var z: float = 0.0
	var x: float = 0.0
	match forward:
		GoDirection.DRIVE:
			z = -1.0
		GoDirection.REVERSE:
			z = 1.0
		GoDirection.NEUTRAL, _:
			z = 0.0
	match left:
		GoDirection.DRIVE:
			x = -1.0
		GoDirection.REVERSE:
			x = 1.0
		GoDirection.NEUTRAL, _:
			x = 0.0
	input_velocity = speed * Vector3(x, 0.0, z).normalized()


func _physics_process(delta):
	update_gravity()
	match jump_state:
		JumpState.PREPARING:
			jump_speed = jump_launch
			jump_state = JumpState.JUMPING
		JumpState.JUMPING:
			jump_speed += -gravity * delta
			if is_on_floor():
				jump_state = JumpState.NOT
		JumpState.NOT:
			jump_speed += -gravity * delta
			if is_on_floor():
				jump_speed = 0.0
	input_velocity.y = jump_speed
	velocity = transform.basis * (
		input_velocity.rotated(Vector3.UP, camera.rotation.y)
	)
	move_and_slide()
	
	
func _process(_delta):
	var v = velocity
	if is_on_floor():
		v = get_real_velocity()
	velocity_debug.set_position(transform.basis.inverse() * v)
