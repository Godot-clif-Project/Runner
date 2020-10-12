extends "res://entities/sword_figher/states/sword_fighter_state.gd"

#func get_animation_data():
	# Name, seek and blend length 
#	return ["jump_start", 0.0, 16.0]
var turn_speed = 180

## Initialize state here: Set animation, add impulse, etc.
func _enter_state():
	entity.emit_one_shot("ParticlesLand")
	entity.on_ground = true
	entity.has_wall_run = true
	entity.has_wall_run_side = true
	entity.air_boosts_left = entity.MAX_AIR_BOOSTS
	entity.model.rotation.z = 0.0
	
	if entity.falling_speed < -25:
		entity.set_animation("jump_land", 0.0, 0.05)
#		entity.velocity *= 0.5
	elif entity.input_listener.is_key_pressed(InputManager.RUN) or entity.input_listener.is_key_pressed(InputManager.UP):
#			set_next_state("off_run_startup")
		if entity.input_listener.is_key_pressed(InputManager.FIRE):
			set_next_state("slide")
			return
			
		entity.velocity *= 0.75
		set_next_state("run")
		return
	else:
		entity.velocity *= 0.75
		set_next_state("run_stop")
		return
##	entity.set_animation("off_hi_r_light", 0, 16.0)
#	entity.on_ground = false
#	._enter_state()
#
## Inverse of enter_state.
##func _exit_state():
##	pass

func _process_state(delta):
	if entity.feet.get_overlapping_bodies().size() == 0:
		set_next_state("fall")
		return
	
	if entity.input_listener.is_key_pressed(InputManager.RIGHT):
		entity.model_container.rotation_degrees.y -= delta * turn_speed
	
	elif entity.input_listener.is_key_pressed(InputManager.LEFT):
		entity.model_container.rotation_degrees.y += delta * turn_speed
		
	else:
		var stick = entity.input_listener.analogs[0]
		if abs(stick) > 0.1:
			entity.model_container.rotation_degrees.y -= stick * delta * turn_speed
	
	entity.accelerate(-5, delta * 0.2)
		
	entity.apply_drag(delta)
	entity.apply_gravity(delta)
	entity.apply_velocity(delta)
	entity.center_camera(delta)

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
