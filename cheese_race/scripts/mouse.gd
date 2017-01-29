extends RigidBody2D

onready var global = get_node("/root/global")
onready var ray_down = get_node("RayCast2D")
onready var gfx = get_node("Gfx")
onready var zzz = get_node("Gfx/Body/Head/Zzz")
onready var camera = get_node("Camera")
onready var animation_player = get_node("Gfx/AnimationPlayer")

const STATE_ALIVE   = 0
const STATE_STARVED = 1
const STATE_DEAD    = 2
const STATE_WON     = 3
var state = STATE_ALIVE

const POSITION_NONE   = 0
const POSITION_GROUND = 1
const POSITION_AIR    = 2
var position = POSITION_NONE
var face_left = false

onready var old_pos = get_pos()
var current_speed = Vector2(200, 0)
var direction = 1
var jump_start_time = 0
var energy setget set_energy

const ENERGY_PER_METER = 0.02

func _ready():
	if get_parent().is_type("VisibilityNotifier2D"):
		var camera = get_node("Camera")
		var rect = get_parent().get_rect()
		camera.set_limit(0, rect.pos.x)
		camera.set_limit(1, rect.pos.y)
		camera.set_limit(2, rect.end.x)
		camera.set_limit(3, rect.end.y)
	ray_down.add_exception(self)
	self.energy = 50

func start():
	set_fixed_process(true)
	set_process_unhandled_input(true)
	animation_player.play("run")

func win():
	if state == STATE_ALIVE:
		state = STATE_WON
		set_process_unhandled_input(false)
		current_speed = Vector2(0, 0)
		animation_player.set_speed(1)
		animation_player.play("win", -1, 1)
		global.play_music("win")

func die():
	if state == STATE_ALIVE:
		state = STATE_DEAD
		animation_player.set_speed(1)
		animation_player.play("die", -1, 1)
		global.play_music("death")

# Energy

func set_energy(e):
	energy = e
	if energy < 0:
		energy = 0
	elif energy > 100:
		energy = 100
	get_tree().call_group(0, "mouse_energy", "set_value", energy)

func eat_cheese(e):
	set_energy(energy + e)
	return true

func starve():
	state = STATE_STARVED
	animation_player.set_speed(1)
	animation_player.play("sleep", -1, 1)
	global.play_music("sleep")

# Input

func _unhandled_input(event):
	if event.is_action_pressed("jump"):
		jump_start_time = OS.get_ticks_msec()
	elif event.is_action_released("jump"):
		if ray_down.is_colliding() && state == STATE_ALIVE:
			var jumping_speed = min(700, 400 + 0.5 * (OS.get_ticks_msec() - jump_start_time))
			apply_impulse(Vector2(0, 0), Vector2(0, -jumping_speed))
	elif event.is_action_pressed("turn"):
		face_left = !face_left

# Movement

func move(speed, acc, delta):
	current_speed.x = lerp(current_speed.x , speed, acc * delta)
	set_linear_velocity(Vector2(current_speed.x,get_linear_velocity().y))
	camera.set_offset(Vector2(lerp(camera.get_offset().x, 0.75*current_speed.x, delta), -100))

func _integrate_forces(state):
	for i in range(state.get_contact_count()):
		var n = state.get_contact_local_normal(i).normalized()
		if n.dot(Vector2(0, -1)) < 0.2:
			set_linear_velocity(200*n)
			die()
			return

func _fixed_process(delta):
	var linear_velocity = get_linear_velocity()
	var target_speed = 0
	if state == STATE_ALIVE:
		set_energy(energy - ENERGY_PER_METER * abs(get_pos().x - old_pos.x))
		old_pos = get_pos()
		target_speed = 2 * energy + 300
		global.set_music_speed(energy)
		if energy <= 0:
			starve()
			return
		if abs(linear_velocity.x) > 1:
			var lvs = sign(linear_velocity.x)
			if direction != lvs:
				direction = lvs
				gfx.set_scale(Vector2(0.1*direction, 0.1))
				zzz.set_scale(Vector2(-direction, 1))
		animation_player.set_speed(linear_velocity.x/100)
		if face_left:
			target_speed = -target_speed
		move(target_speed, 2, delta)

func game_call(f):
	get_tree().call_group(0, "game", f)
