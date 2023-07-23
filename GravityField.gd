extends Area3D

var player: Node3D = null


func _on_body_entered(body):
	player = body


func _on_body_exited(_body):
	player = null
	

func _process(_delta):
	if player == null:
		return
	player.new_gravity(gravity_point_center)
