extends Node


onready var world = get_tree().get_root().get_node("World")
onready var pc = get_parent().get_parent().get_parent()
onready var mm = pc.get_node("MovementManager")
onready var gm = pc.get_node("GunManager")

func state_process():
	pc.move_dir = get_move_dir()
	mm.velocity = get_velocity()
	var new_velocity = pc.move_and_slide_with_snap(mm.velocity, mm.snap_vector, mm.FLOOR_NORMAL, true)
	
	mm.velocity.y = new_velocity.y #only set y portion because we're doing move and slide with snap
	
	
	
	if pc.is_on_floor() and not pc.is_on_ssp:
		if Input.is_action_pressed("look_down") and pc.controller_id == 0 or\
		Input.is_action_pressed("sasuke_down") and pc.controller_id == 1:
			mm.change_state("run")

	if pc.is_on_ceiling() and mm.bonk_timeout.time_left == 0:
		mm.bonk("bonk")



func get_move_dir():
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("look_down") - Input.get_action_strength("look_up"))



func get_velocity():
	var out = mm.velocity
	
	out.y = pc.move_dir.y * mm.speed.y * 0.5
	out.x = 0
	if Input.is_action_just_pressed("jump"):
		mm.change_state("jump") #TODO fix
		out.y = mm.speed.y * -1.0

	if abs(out.x) < mm.min_x_velocity: out.x = 0 #clamp velocity
		
	return out





func enter():
	mm.snap_vector = Vector2.ZERO
	pc.set_collision_mask_bit(9, false) #ssp
	gm.disable()
	
func exit():
	pc.set_collision_mask_bit(9, true) #ssp
	gm.enable()
