extends Node

const SFX_PLAYER = preload("res://src/Audio/SFX.tscn")
const POS_SFX_PLAYER = preload("res://src/Audio/PosSFX.tscn")
const MUSIC_PLAYER = preload("res://src/Audio/Music.tscn")

signal interrupt_finished
signal fadeout_finished
signal players_updated

export var sfx_dict: Dictionary = {
	"sound_test": preload("res://assets/SFX/Placeholder/snd_menu_move.ogg"),
	"ui_accept": preload("res://assets/SFX/Placeholder/snd_menu_select.ogg"),
	"ui_deny": preload("res://assets/SFX/Placeholder/snd_quote_bonkhead.ogg"),
	"ui_move": preload("res://assets/SFX/Placeholder/snd_menu_move.ogg"),
	
	"door": preload("res://assets/SFX/Placeholder/snd_door.ogg"),
	"locked": preload("res://assets/SFX/Placeholder/snd_gun_click.ogg"),
	"click": preload("res://assets/SFX/Placeholder/snd_gun_click.ogg"),
	"ammo_refill": preload("res://assets/SFX/Placeholder/snd_get_missile.ogg"),
	"chest": preload("res://assets/SFX/Placeholder/snd_chest_open.ogg"),
	
	"break_block": preload("res://assets/SFX/Placeholder/snd_block_destroy.ogg"),
	"break_grass": preload("res://assets/SFX/Placeholder/snd_explosion2.ogg"),
	
	"save": preload("res://assets/SFX/Placeholder/snd_health_refill.ogg"),
	
	"pc_die": preload("res://assets/SFX/Placeholder/snd_quote_die.ogg"),
	"pc_hurt": preload("res://assets/SFX/Placeholder/snd_quote_hurt.ogg"),
	"pc_jump": preload("res://assets/SFX/Placeholder/snd_quote_jump.ogg"),
	"pc_step": preload("res://assets/SFX/Placeholder/snd_quote_walk.ogg"),
	
	"gun_click": preload("res://assets/SFX/Placeholder/snd_gun_click.ogg"),
	"gun_shift": preload("res://assets/SFX/Placeholder/snd_switchweapon.ogg"),
	"gun_pistol": preload("res://assets/SFX/Placeholder/snd_polar_star_l1_2.ogg"),
	"gun_revolver": preload("res://assets/SFX/Placeholder/snd_polar_star_l3.ogg"),
	"gun_shotgun": preload("res://assets/SFX/Placeholder/snd_missile_hit.ogg"),
	"gun_grenade": preload("res://assets/SFX/Placeholder/snd_expl_small.ogg"),
	"gun_grenade_bounce": preload("res://assets/SFX/Placeholder/snd_thud.ogg"),
	"gun_star_bounce": preload("res://assets/SFX/Placeholder/snd_splash.ogg"),
	
	"bullet_thud": preload("res://assets/SFX/Placeholder/snd_shot_hit.ogg"),
	"bullet_clink": preload("res://assets/SFX/Placeholder/snd_shot_bounce.ogg"),
	"bullet_destroy" : preload("res://assets/SFX/Placeholder/snd_expl_small.ogg"),
	
	"get_hp": preload("res://assets/SFX/Placeholder/snd_health_refill.ogg"),
	"xp": preload("res://assets/SFX/Placeholder/snd_xp_bounce.ogg"),
	"get_xp": preload("res://assets/SFX/Placeholder/snd_get_xp.ogg"),
	"get_ammo": preload("res://assets/SFX/Placeholder/snd_get_missile.ogg"),
	
	"level_up": preload("res://assets/SFX/Placeholder/snd_level_up.ogg"),
	
	"enemy_jump": preload("res://assets/SFX/Placeholder/snd_critter_jump.ogg"),
	"enemy_croak": preload("res://assets/SFX/FrogCroak.ogg"),
	"enemy_hurt": preload("res://assets/SFX/Placeholder/snd_enemy_hurt.ogg"),
	"enemy_shoot": preload("res://assets/SFX/Placeholder/snd_em_fire.ogg"),
	
	"npc_dialog": preload("res://assets/SFX/Placeholder/snd_msg.ogg"),
}

export var music_dict: Dictionary = {
	"sound_test": preload("res://assets/SFX/Placeholder/snd_menu_move.ogg"),
	"get_item": preload("res://assets/Music/Placeholder/Got Item!.ogg"),
	"get_hp": preload("res://assets/Music/Placeholder/Get Heart Tank!.ogg"), #TODO: rename
	"gameover": preload("res://assets/Music/Placeholder/Gameover.ogg"),
	"victory": preload("res://assets/Music/Placeholder/Victory!.ogg"),
	
	"none": preload("res://assets/Music/Placeholder/XXXX.ogg"),
	
	"village": preload("res://assets/Music/Placeholder/Mimiga Town.ogg"),
	"access": preload("res://assets/Music/Placeholder/Access.ogg"),
	"safety": preload("res://assets/Music/Placeholder/Safety.ogg"),
	
	"theme": preload("res://assets/Music/Placeholder/laputaintro.ogg"),
}



export var remove_duplicate_sfx = false
export var sfx_player_max = 999 #8 #TODO: broken, triggering this causes crash from queue_free on deleted node
var sfx_players = []
var sfx_queue = []
export var remove_recent_duplicate_sfx = true
export var sfx_recent_time = 0.05
var sfx_recent = []

export var music_player_max = 1
var music_players = []
var music_queue = []

#export var track_player_max = 1
#var track_players = []
#var track_queue = []

export var interrupt_player_max = 1
var interrupt_players = []
var interrupt_queue = []



func _ready():
	pass

func play(sfx_string: String):
	if sfx_dict.has(sfx_string):
		
		if sfx_queue.has(sfx_string) and remove_duplicate_sfx:
			print("WARNING: SFX already playing! Removed SFX with name: " + sfx_string)
			return
		
		if remove_recent_duplicate_sfx:
			if sfx_recent.has(sfx_string):
				print("WARNING: SFX already playing! Removed SFX with name: " + sfx_string)
				return
			else:
				_do_recent_time(sfx_string)
		
		var player = _add_player("sfx", sfx_string)
		while sfx_players.size() > sfx_player_max:
			_clear_player("sfx", sfx_players[0])
		
		yield(player, "finished")
		_clear_player("sfx", player)
		
	else:
		printerr("ERROR: No SFX with name: " + sfx_string)

func _do_recent_time(sfx_string):
	sfx_recent.append(sfx_string)
	yield(get_tree().create_timer(sfx_recent_time), "timeout")
	sfx_recent.erase(sfx_string)

func play_pos(sfx_string: String, actor: Node):
	if sfx_dict.has(sfx_string):
		
		if sfx_queue.has(sfx_string) and remove_duplicate_sfx:
			print("WARNING: SFX already playing! Removed SFX with name: " + sfx_string)
			return
		
		if remove_recent_duplicate_sfx:
			if sfx_recent.has(sfx_string):
				print("WARNING: SFX already playing! Removed SFX with name: " + sfx_string)
				return
			else:
				_do_recent_time(sfx_string)
		
		var player = _add_player("sfx", sfx_string)
		while sfx_players.size() > sfx_player_max:
			_clear_player("sfx", sfx_players[0])
		
		yield(player, "finished")
		_clear_player("sfx", player)
		
	else:
		printerr("ERROR: No SFX with name: " + sfx_string)

func play_master(sfx_string: String):
	if sfx_dict.has(sfx_string):
		var player = _add_player("sfx", sfx_string)
		player.bus = "Master"
		while sfx_players.size() > sfx_player_max:
			_clear_player("sfx", sfx_players[0])
		yield(player, "finished")
		_clear_player("sfx", player)
	else:
		printerr("ERROR: No SFX with name: " + sfx_string)

func play_music(music_string):
	if music_dict.has(music_string):
		if music_queue.has(music_string): #don't play if already playing
			return
		
		var player = _add_player("music", music_string)
		while music_players.size() > music_player_max:
			_clear_player("music", music_players[0])
		
		yield(player, "finished")
		_clear_player("music", player)
	
	else:
		printerr("ERROR: No music with name: " + music_string)



func play_track(track_path):
#		if track_queue.has(track_string): #don't play if already playing
#			return
			
	var file_name = track_path.get_file().get_basename()
	var file_info = file_name.split("_")
	
	var dir = Directory.new()
	var intro_path = track_path.get_base_dir().plus_file(file_info[0] + "_" + file_info[1] + "_Intro.wav")
	var loop_path = track_path.get_base_dir().plus_file(file_info[0] + "_" + file_info[1] + ".wav")
	var outro_path = track_path.get_base_dir().plus_file(file_info[0] + "_" + file_info[1] + "_Outro.wav")
	
	
	var track = {}
	track["producer"] = file_info[0]
	track["name"] = file_info[1]
	track["intro"] = ""
	track["loop"] = loop_path
	track["outro"] = ""
	
	if dir.file_exists(intro_path):
		track["intro"] = intro_path
	if dir.file_exists(outro_path):
		track["intro"] = outro_path


	var player
	if track["intro"] != "": #has intro
		player = _add_track_player(track["intro"])
		while music_players.size() > music_player_max:
			_clear_player("music", music_players[0])
#		yield(get_tree(), "idle_frame")
		yield(player, "finished")
		player.stream = load(track["loop"])
		player.play()
	else:
		player = _add_track_player(track["loop"])
	
#	_clear_player("music", player)



func play_interrupt(music_string): #play_time, wait_start, wait_end
	for p in music_players: #pause music players
		p.stream_paused = true

	var player = _add_player("interrupt", music_string)
	while interrupt_players.size() > interrupt_player_max:
		_clear_player("interrupt", interrupt_players[0])
	
	yield(player, "finished")
	_clear_player("interrupt", player)
	emit_signal("interrupt_finished")
	for p in music_players: #unpause music players
		p.stream_paused = false


#####

func _add_player(type, string):
	get(type + "_queue").append(string)
	var player = SFX_PLAYER.instance() if type == "sfx" else MUSIC_PLAYER.instance()
	get(type + "_players").append(player)
	add_child(player)
	player.stream = sfx_dict[string] if type == "sfx" else music_dict[string]
	player.play()
	emit_signal("players_updated")
	return player

func _add_track_player(path):
	#get("music_queue").append(player)
	var player = MUSIC_PLAYER.instance()
	get("music_players").append(player)
	add_child(player)
	player.stream = load(path)
	player.play()
	emit_signal("players_updated")
	return player


func _add_pos_player(string, actor):
	sfx_queue.append(string)
	var player = POS_SFX_PLAYER.instance()
	sfx_players.append(player)
	actor.add_child(player)
	player.stream = sfx_dict[string]
	player.play()
	emit_signal("players_updated")
	return player

func _clear_player(type, player):
		get(type + "_queue").pop_front()
		get(type + "_players").pop_front()
		player.queue_free()
		emit_signal("players_updated")

#####

func stop_sfx(): #TODO: shouldnt these methods use _clear_player?
	for p in sfx_players:
		p.queue_free()
		emit_signal("players_updated")

func stop_music():
	for p in music_players:
		p.queue_free()
		emit_signal("players_updated")

func fade_music(duration = 1.0):
	if music_players.empty():
		return
	
	var player = music_players.front()
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(player, "volume_db", player.volume_db, -80, duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_completed")
	_clear_player("music", player)
	
	
	tween.queue_free()
	emit_signal("fadeout_finished")
