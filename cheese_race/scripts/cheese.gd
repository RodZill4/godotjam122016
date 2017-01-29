tool
extends Area2D

export(float) var energy = 25 setget set_energy

onready var animation_player = get_node("AnimationPlayer")

func _ready():
	pass

func _on_Cheese_body_enter(body):
	if animation_player.get_current_animation() != "eat" && body.has_method("eat_cheese") && body.eat_cheese(energy):
		animation_player.play("eat")
		get_node("SamplePlayer2D").play("cheese")

func set_energy(e):
	energy = e
	set_scale(sqrt(energy)*0.2*Vector2(1, 1))

func get_energy():
	return energy
