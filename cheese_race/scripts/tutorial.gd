extends VisibilityEnabler2D

onready var tutorials = get_node("Tutorials")
onready var background = tutorials.get_node("Background")

func show_tutorial(b, n):
	var tutorials = get_node("Tutorials")
	var background = tutorials.get_node("Background")
	background.get_node(n).show()
	background.show()
	get_tree().set_pause(true)

func hide_tutorial():
	background.hide()
	for c in background.get_children():
		c.hide()
	get_tree().set_pause(false)


func close_tutorial():
	pass # replace with function body


func open_tutorial( body ):
	pass # replace with function body
