extends "res://entities/sword_figher/states/sword_fighter_state.gd"

#func get_animation_data():
	# Name, seek and blend length 
#	return ["jump_start", 0.0, 16.0]
var ang_momentum = 0.0
var rot_drag = 1
var rot_speed = 5
var rot_lerp = 5.0
var max_turn_speed = 6.0


## Initialize state here: Set animation, add impulse, etc.
func _enter_state():
	entity.on_ground = true
	entity.has_wall_run = true
	entity.has_wall_run_side = true
	entity.air_boosts_left = entity.MAX_AIR_BOOSTS
	entity.model.rotation.z = 0.0
	entity.ground_drag = 8
#	entity.raycast_cling.enabled = false
#	entity.clingbox.monitoring = false
	
	entity.emit_one_shot("ParticlesLand")
	entity.play_sound("land")
	
#	entity.velocity *= 0.75

	if entity.prev_velocity.y < -20:
		entity.set_animation("jump_land", 0.0, 0.05)
#		entity.hp -= 300 * (entity.falling_speed / -50.0)
#		entity.velocity *= 0.5
	elif entity.input_listener.is_key_pressed(InputManager.FIRE):
		set_next_state("slide")
		return
	elif entity.input_listener.is_key_pressed(InputManager.RUN):# or entity.input_listener.is_key_pressed(InputManager.UP):
		set_next_state("run")
		entity.velocity  *= 0.75
		return
	else:
		if entity.horizontal_speed < 4:
			set_next_state("offensive_stance")
#			entity.set_animation("run_break", 0.0, 0.05)
		else:
			entity.velocity *= 0.75
#			set_next_state("skid")
			entity.set_animation("run_break", 0, 0.05)
		return
##	entity.set_animation("off_hi_r_light", 0, 16.0)
#	entity.on_ground = false
#	._enter_state()
#
## Inverse of enter_state.
##func _exit_state():
##	pass

func _process_state(delta):
	if entity.horizontal_speed < 4.0:
			set_next_state("offensive_stance")
			return
			
	if entity.feet.get_overlapping_bodies().size() == 0:
		set_next_state("fall")
		return
	
	ang_momentum = lerp(ang_momentum, -add_direction() * max_turn_speed, delta * rot_lerp)
	
	entity.model_container.rotation_degrees.y += ang_momentum * float(1 - entity.target_speed / entity.BOOST_SPEED * 0.5)
	entity.emit_signal("rotation_changed", entity.model_container.rotation.y)
	
#	if entity.input_listener.is_key_pressed(InputManager.FIRE):
#		entity.ground_drag = 15
#	else:
#		entity.ground_drag = 8.5
		
	entity.apply_drag(delta)
	entity.target_speed = entity.horizontal_speed
	
	entity.apply_gravity(delta)
	entity.apply_velocity(delta)
	entity.align_to_floor(delta)
	entity.center_camera(delta * 2, Vector2.ZERO)

#func _touched_surface(surface):
#	if surface == "floor": #and entity.flags.is_active:
#		entity.on_ground = true
##		print(falling_speed)
#		if falling_speed < -22:
#			entity.set_animation("jump_land", 0.0, 16.0)
#		elif entity.input_listener.is_key_pressed(InputManager.RUN):
#			set_next_state("run")
#		else:
#			set_next_state("offensive_stance")
			

func _animation_finished(anim_name):
	if anim_name == "jump_land":
		if entity.input_listener.is_key_pressed(InputManager.RUN) or entity.input_listener.is_key_pressed(InputManager.UP):
			set_next_state("run")
			return
		else:
			set_next_state("run_stop")
			return
	else:
		set_next_state("offensive_stance")
		
#
#func _flag_changed(flag, state):
#	if flag == "is_evade_cancelable" and state:
#			set_next_state("walk")
#		if entity.input_listener.is_key_pressed(InputManager.DOWN):
#			set_next_state("walk")
#		if entity.input_listener.is_key_pressed(InputManager.LEFT):
#			set_next_state("walk")
#		if entity.input_listener.is_key_pressed(InputManager.RIGHT):
#			set_next_state("walk")
#

#func _received_input(key, state):
#	if entity.on_ground:
#		._received_input(key, state)
		
#	if entity.flags.is_stringable:
#		if state:
#			if key == InputManager.LIGHT:
#				set_next_state("off_hi_fierce")
#			if key == InputManager.HEAVY:
#				set_next_state("off_kick")
