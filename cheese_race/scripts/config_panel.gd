extends Control

onready var global = get_node("/root/global")
export(bool) var EnableReset = false

func show():
	var s = global.get_audio_setup()
	get_node("AnimationPlayer").play("show")
	var p = get_node("Center/PanelPosition/Panel")
	p.get_node("Sound").set_pressed(s.sound)
	p.get_node("Music").set_pressed(s.music)
	p.get_node("SoundVolume").set_value(s.sound_volume)
	p.get_node("MusicVolume").set_value(s.music_volume)
	p.get_node("ResetProgress").set_disabled(!EnableReset)

func _on_MusicVolume_value_changed(value):
	var s = global.get_audio_setup()
	s.music_volume = value
	global.set_audio_setup(s)

func _on_SoundVolume_value_changed(value):
	var s = global.get_audio_setup()
	s.sound_volume = value
	global.set_audio_setup(s)

func _on_Music_toggled(value):
	var s = global.get_audio_setup()
	s.music = value
	global.set_audio_setup(s)

func _on_Sound_toggled(value):
	var s = global.get_audio_setup()
	s.sound = value
	global.set_audio_setup(s)


func _on_ResetProgress_pressed():
	global.reset_game_state()
