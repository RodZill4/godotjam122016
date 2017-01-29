extends Node2D

onready var global = get_node("/root/global")
onready var game_panel = get_node("Canvas/UI/GamePanel")

var current_level_name = null setget set_current_level_name
var next_level_name = null
var current_level = null

onready var coins_label = get_node("Canvas/UI/GameUI/Coins")
var total_coins     = 0
var remaining_coins = 0

func _ready():
	pass

func set_current_level_name(n):
	current_level_name = n
	get_node("Canvas/UI/CountDown/Level").set_text("Level "+current_level_name)
	game_panel.set_level(current_level_name, global.level_get_stars(current_level_name))
	
func load_level(level_name):
	get_tree().set_pause(false)
	self.current_level_name = level_name
	global.load_scene("res://levels/l"+level_name+".tscn", self, "start_level")

func start_level(scene):
	if current_level != null:
		remove_child(current_level)
		current_level.free()
	if !global.lives_add(-1):
		return
	current_level = scene.instance()
	add_child(current_level)
	global.play_music("run", true)
	count_total_coins()
	get_node("AnimationPlayer").play("countdown")

func start():
	get_node("World/Mouse").start()

func win():
	var percent = remaining_coins * 100 / total_coins
	var stars = 0
	if percent == 0:
		stars = 3
	elif percent <= 30:
		stars = 2
	elif percent <= 70:
		stars = 1
	global.level_set_stars(current_level_name, stars)
	game_panel.set_level(current_level_name, global.level_get_stars(current_level_name))
	game_panel.show(false, next_level_name != null)

func lose():
	game_panel.show(false, next_level_name != null)

func _on_GamePanel_retry_level():
	if global.lives_get().count > 0:
		load_level(current_level_name)
	else:
		get_node("Canvas/UI/MoreLives").show()

func _on_GamePanel_next_level():
	if global.lives_get().count > 0:
		if next_level_name != null:
			load_level(next_level_name)
			next_level_name = null
	else:
		get_node("Canvas/UI/MoreLives").show()

func _on_PauseButton_pressed():
	global.play_sound("button")
	get_node("Canvas/UI/GamePanel").show(true, next_level_name != null)
	get_tree().set_pause(true)

func _on_GamePanel_show_map():
	get_tree().set_pause(false)
	global.switch_to_scene("res://map.tscn")

# Coins counters

func count_remaining_coins():
	remaining_coins = get_tree().get_nodes_in_group("coins").size()
	coins_label.set_text(str(total_coins - remaining_coins) + " / " + str(total_coins))
	
func count_total_coins():
	total_coins = get_tree().get_nodes_in_group("coins").size()
	remaining_coins = total_coins
	coins_label.set_text("0 / " + str(total_coins))
