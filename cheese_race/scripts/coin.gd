extends Area2D

var looted = false

func _ready():
	pass

func _on_Coin_body_enter(body):
	if !looted:
		looted = true
		remove_from_group("coins")
		get_tree().call_group(SceneTree.GROUP_CALL_DEFAULT, "coin_counters", "count_remaining_coins")
		get_node("AnimationPlayer").play("loot")
		get_node("SamplePlayer").play("coin")
