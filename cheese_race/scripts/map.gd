extends Control

func _ready():
	get_node("/root/global").play_music("title", false, true)
	pass

func _on_ConfigButton_pressed():
	get_node("ConfigPanel").show()
