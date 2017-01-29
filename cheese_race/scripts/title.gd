extends Control

onready var global = get_node("/root/global")
var current_page = 1

func _ready():
	global.play_music("title", false, true)

func _on_Play_pressed():
	button_sound()
	global.switch_to_scene("res://map.tscn")

func _on_Help_pressed():
	button_sound()
	var doc = get_node("Doc")
	if doc.is_visible():
		doc.hide()
	else:
		show_doc()

func button_sound():
	global.play_sound("button")

func _on_Quit_pressed():
	button_sound()
	get_tree().quit()

func show_doc(p = 1):
	current_page = p
	var pages = get_node("Doc/Pages")
	for c in get_node("Doc/Pages").get_children():
		if c.get_name() == "Page"+str(p):
			c.show()
		else:
			c.hide()
	get_node("Doc").show()
	get_node("Doc/Prev").set_disabled(!pages.has_node("Page"+str(p-1)))
	get_node("Doc/Next").set_disabled(!pages.has_node("Page"+str(p+1)))

func _on_Prev_pressed():
	button_sound()
	show_doc(current_page - 1)

func _on_Next_pressed():
	button_sound()
	show_doc(current_page + 1)
