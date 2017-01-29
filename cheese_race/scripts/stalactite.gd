extends Node2D

func _on_Stalactite_body_enter(body):
	if body.get_name() == "Mouse":
		get_node("Stalactite").set_gravity_scale(1)
