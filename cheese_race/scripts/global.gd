extends Node

onready var music = get_node("Music")
var current_song = null
var music_scalable = false
var music_scale = 1

onready var progress_bar = get_node("ProgressBar")
var game = null
var loader = null
var scene_name  = null
var scene = null
var call_object = null
var call_method = null

const game_state_file = "user://cr_savedata.bin"
onready var savegame_key = "CR"+OS.get_unique_ID()
var game_state = { }

const LIVES_INITIAL   = 3
const LIVES_MAX       = 5
const LIVES_TIME      = 30

func _ready():
	load_game_state()
	set_audio_setup()
	lives_update()

# music

func play_music(song, scalable = false, cont = false):
	if cont && song == current_song:
		return
	music.set_tempo_scale(1)
	current_song = song
	music_scalable = scalable
	music.set_stream(load("res://music/"+song+".it"))
	music.set_loop(true)
	music_scale = 1
	music.play()

func set_music_speed(s):
	if music_scalable:
		s = 0.1 * round(8+0.12*s)
		if music_scale != s:
			music_scale = s
			music.set_tempo_scale(music_scale)

# sounds

func play_sound(s):
	get_node("Sound").play(s)

# load a scene

func poll_loader():
	var err = loader.poll()
	if err == ERR_FILE_EOF:
		scene = loader.get_resource()
		loader = null
		call_object.call_deferred(call_method, scene)
		call_object = null
		call_method = null
	elif err == OK:
		# show progress
		err = null
		return false
	else:
		# show error
		loader = null
	return true

func _process(delay):
	if loader != null:
		for i in range(10):
			if poll_loader():
				set_process(false)
				progress_bar.hide()
				return
		progress_bar.set_value(loader.get_stage() * 100 / loader.get_stage_count())

func load_scene(n, o, m):
	if scene_name == n:
		o.call_deferred(m, scene)
	else:
		loader = ResourceLoader.load_interactive(n)
		if loader != null:
			scene_name = n
			scene = null
			call_object = o
			call_method = m
			progress_bar.show()
			set_process(true)

# switch to scene

func switch_to_scene(s):
	var root = get_tree().get_root()
	var curScene = root.get_child(root.get_child_count()-1)
	curScene.queue_free()
	var scene = load(s).instance()
	root.add_child(scene)

# load a game

func load_game(l):
	var root = get_tree().get_root()
	var curScene = root.get_child(root.get_child_count()-1)
	curScene.queue_free()
	game = preload("res://game.tscn").instance()
	root.add_child(game)
	game.load_level(l)

# user configuration

func get_game_state_var(n, d):
	if game_state.has(n):
		return game_state[n]
	else:
		return d

func set_game_state_var(n, v):
	game_state[n] = v

func load_game_state():
	var f = File.new()
	var err = f.open_encrypted_with_pass(game_state_file, File.READ, savegame_key)
	if err == 0:
		game_state = f.get_var()
	f.close()
	unlock_level("1")

func save_game_state():
	var f = File.new()
	var err = f.open_encrypted_with_pass(game_state_file, File.WRITE, savegame_key)
	if err == 0:
		f.store_var(game_state)
	f.close()

func reset_game_state():
	game_state = { }
	unlock_level("1")
	save_game_state()

# audio setup

func get_audio_setup():
	return {
		sound        = get_game_state_var("Setup/Sound", true),
		sound_volume = get_game_state_var("Setup/SoundVolume", 100),
		music        = get_game_state_var("Setup/Music", true),
		music_volume = get_game_state_var("Setup/MusicVolume", 100)
	}

func set_audio_setup(s = null):
	if s == null:
		s = get_audio_setup()
	set_game_state_var("Setup/Sound", s.sound)
	set_game_state_var("Setup/SoundVolume", s.sound_volume)
	set_game_state_var("Setup/Music", s.music)
	set_game_state_var("Setup/MusicVolume", s.music_volume)
	save_game_state()
	if !s.music:
		s.music_volume = 0
	AudioServer.set_event_voice_global_volume_scale(0.01 * s.music_volume)
	if !s.sound:
		s.sound_volume = 0
	AudioServer.set_fx_global_volume_scale(0.01 * s.sound_volume)

# unlocked levels

func level_is_locked(l):
	return !get_game_state_var("unlocked/"+l, false)

func unlock_level(l):
	set_game_state_var("unlocked/"+l, true)
	save_game_state()

func level_get_stars(l):
	return get_game_state_var("stars/"+l, 0)

func level_set_stars(l, s):
	var stars = get_game_state_var("stars/"+l, 0)
	if s > stars:
		set_game_state_var("stars/"+l, s)
		lives_add(s - stars)

# lives

func lives_update():
	if get_game_state_var("lives/last_updated", 0) == 0:
		set_game_state_var("lives/count", LIVES_INITIAL)
		set_game_state_var("lives/last_updated", OS.get_unix_time())
		save_game_state()

func lives_get():
	var l = get_game_state_var("lives/count", 0)
	var t = OS.get_unix_time() - get_game_state_var("lives/last_updated", 0)
	l += t / LIVES_TIME
	if l >= LIVES_MAX:
		l = LIVES_MAX
		t = 0
	else:
		t = LIVES_TIME - (t % LIVES_TIME)
	return { count = l, time = t }

func lives_add(x):
	var l = lives_get().count
	if l+x < 0:
		return false
	if l == LIVES_MAX && l+x < LIVES_MAX:
		set_game_state_var("lives/count", l+x)
		set_game_state_var("lives/last_updated", OS.get_unix_time())
	else:
		set_game_state_var("lives/count", get_game_state_var("lives/count", 0)+x)
	save_game_state()
	return true
