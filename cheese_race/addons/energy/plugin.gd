tool
extends EditorPlugin

var progress_bar = null
var object = null

func _enter_tree():
	pass

func _exit_tree():
	pass

func handles(o):
	var n = o.get_name()
	return n.left(4) == "Coin" || n.left(6) == "Cheese" || n == "Mouse" || n == "Goal"

func edit(o):
	object = o

func make_visible(b):
	if b:
		if progress_bar == null:
			progress_bar = preload("res://addons/energy/energy.tscn").instance()
			add_control_to_container(CONTAINER_CANVAS_EDITOR_MENU, progress_bar)
		progress_bar.show_object_energy(object)
	elif progress_bar != null:
		progress_bar.queue_free()
		progress_bar = null
