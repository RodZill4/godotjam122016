extends Control

onready var global = get_node("/root/global")
var next_signal = null

signal retry_level
signal next_level
signal show_map
signal show_setup_window

func show(has_close, has_next):
	var close_button = get_node("Center/PanelPosition/Panel/Close")
	if has_close:
		close_button.show()
	else:
		close_button.hide()
	get_node("Center/PanelPosition/Panel/Next").set_disabled(!has_next)
	get_node("AnimationPlayer").play("show")
	var p = get_node("Center/PanelPosition/Panel")

func hide(s = null):
	global.play_sound("button")
	next_signal = s
	get_node("AnimationPlayer").play("hide")
	var p = get_node("Center/PanelPosition/Panel")

func on_hide():
	get_tree().set_pause(false)
	if next_signal != null:
		emit_signal(next_signal)

func set_level(n, s):
	var panel = get_node("Center/PanelPosition/Panel")
	panel.get_node("Label").set_text("Level "+n)
	for i in range(1, 4):
		var star = panel.get_node("Star"+str(i))
		if i <= s:
			star.show()
		else:
			star.hide()