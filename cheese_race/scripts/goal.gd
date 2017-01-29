extends Area2D

export(String) var next_level = null

func _ready():
	pass

func _on_Goal_body_enter(body):
	if body.has_method("win"):
		body.win()
		if next_level != null:
			var global = get_node("/root/global")
			global.unlock_level(next_level)
			global.game.next_level_name = next_level
	else:
		print("Something reached goal, but not player")

func get_energy_gain():
	return 0
