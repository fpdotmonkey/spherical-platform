extends Area3D


func _on_body_entered(body):
	body.new_center(gravity_point_center)


func _on_body_exited(_body):
	# TODO take away player gravity
	pass
