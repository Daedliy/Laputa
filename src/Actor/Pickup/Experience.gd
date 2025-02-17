extends Actor

var direction
export var bounciness: float = .75
export var minimum_speed: float = .5
var start_velocity

export var rng_min_speed = 50
export var rng_max_speed = 100

var value: int

var decay_time = 4.0
var pop_time = 1.0

func _ready():
	$DecayTimer.start(decay_time)
	direction = randomize_direction()
	speed = randomize_speed()
	velocity = get_velocity(speed, direction)
	start_velocity = abs(velocity.x) + abs(velocity.y)/2 #used to calculate animation slowdown

	match value:
		1:
			if velocity.x < 0: $AnimationPlayer.play("SmallLeft")
			else: $AnimationPlayer.play("SmallRight")
		5:
			if velocity.x < 0: $AnimationPlayer.play("MediumLeft")
			else: $AnimationPlayer.play("MediumRight")
		20:
			$AnimationPlayer.play("FourRight")

func randomize_direction():
	rng.randomize()
	return Vector2(sign(rng.randf_range(-1.0, 1.0)), -1)
	
func randomize_speed():
	rng.randomize()
	return Vector2(rng.randf_range(rng_min_speed, rng_max_speed),rng.randf_range(rng_min_speed, rng_max_speed))

func _physics_process(delta):
	if abs(velocity.x) > minimum_speed and abs(velocity.y) > minimum_speed:
		var collision = move_and_collide(velocity * delta)
		if collision:
			velocity *= bounciness
			velocity = velocity.bounce(collision.normal)
			#if $AnimationPlayer.is_playing():
			am.play_pos("xp", self)
			
	velocity.y += gravity * get_physics_process_delta_time()

	var ave_velocity = abs(velocity.x) + abs(velocity.y)/2 #used to calculate animation slowdown
	$AnimationPlayer.playback_speed = ave_velocity / start_velocity
	
	if $AnimationPlayer.playback_speed > 1:
		$AnimationPlayer.playback_speed = 1
	if $AnimationPlayer.playback_speed < .1:
		$AnimationPlayer.stop()


	
func get_velocity(speed, scoped_direction) -> Vector2:
	var out = velocity
	
	out.x = speed.x * scoped_direction.x
	out.y += gravity * get_physics_process_delta_time()
	if scoped_direction.y == -1.0:
		out.y = speed.y * scoped_direction.y

	return out


func _on_DecayTimer_timeout():
	$FlashPlayer.play("Flash")
	$PopTimer.start(pop_time)
	

func _on_PopTimer_timeout():
	$FlashPlayer.play("Steady")
	match value:
		1: $AnimationPlayer.play("SmallPop")
		5: $AnimationPlayer.play("MediumPop")
		_: $AnimationPlayer.play("MediumPop")
	yield($AnimationPlayer, "animation_finished")
	queue_free()


func _on_Timer_timeout():
	pass # Replace with function body.
