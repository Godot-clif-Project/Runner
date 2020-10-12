extends "res://entities/sword_figher/states/sword_fighter_offensive_moves.gd"

#func get_animation_data():
	# Name, seek and blend length 
#	return ["off_h_r_heavy", 0.0, 5.0]
#var direction = 0
#var released_up = false

## Initialize state here: Set animation, add impulse, etc.
func _enter_state():
	entity.ground_drag = 15
#	entity.velocity *= 0.5
	if entity.input_listener.is_key_pressed(InputManager.RIGHT):
		entity.add_impulse(Vector3(10.0, 0.0, 0.0))
		entity.set_animation("def_step_r", 0, 0.05)
	elif entity.input_listener.is_key_pressed(InputManager.LEFT):
		entity.add_impulse(Vector3(-10.0, 0.0, 0.0))
		entity.set_animation("def_step_l", 0, 0.05)
#	._enter_state()
#
## Inverse of enter_state.
#func _exit_state():
#	if entity.get_current_animation() == "run_loop":
#		entity.tween_camera_position(start_camera_pos)
#	._exit_state()
#	pass
#
#func _process_state(delta):
#	entity.accelerate(-13, delta)
#	pass

##func _animation_blend_started(anim_name):
##	print(anim_name)
##	set_next_state("idle")
##	if anim_name == "off_h_r_heavy":
#
func _animation_finished(anim_name):
	if entity.input_listener.is_key_pressed(InputManager.RUN):
		set_next_state("run")
	else:
		set_next_state("run_stop")
		
#	if released_up:
#		entity.set_animation("off_run_stop", 0, 10.0)
#		set_next_state("offensive_stance")
#	else:
		
#			entity.set_animation("run_loop", 0, -1.0)
#			if entity.input_listener.is_key_pressed(InputManager.RIGHT):
#				direction = 1
#				entity.tween_camera_position(0.0)
#			elif entity.input_listener.is_key_pressed(InputManager.LEFT):
#				direction = -1
#				entity.tween_camera_position(0.0)
				
#	if anim_name == "off_run_stop":
#		set_next_state("offensive_stance")
	

func _flag_changed(flag, state):
	if flag == "is_evade_cancelable" and state:
		if entity.input_listener.is_key_pressed(InputManager.RUN):
			set_next_state("run")
		else:
			set_next_state("run_stop")
#		if entity.input_listener.is_key_pressed(InputManager.RUN):
#			set_next_state("walk")
#		if entity.input_listener.is_key_pressed(InputManager.DOWN):
#			set_next_state("walk")
#		if entity.input_listener.is_key_pressed(InputManager.LEFT):
#			set_next_state("walk")
#		if entity.input_listener.is_key_pressed(InputManager.RIGHT):
#			set_next_state("walk")

func get_possible_transitions():
	return [
		"air_atk",
		"sidestep",
		"run",
		"run_stop",
		"jump",
		]

func _received_input(key, state):
	if entity.flags.is_stringable:
		._received_input(key, state)
#	if state:
#		if key == InputManager.RUN:
#			set_next_state("run")
#			return
	pass
#	._received_input(key, state)
#	if entity.flags.is_stringable:
	
#	if state:
#		if key == InputManager.DOWN:
#			set_next_state("run_stop")
#	if not state:
#		if key == :
#			released_up = true
#			entity.set_animation("off_run_stop", 0, 10.0)
				
#				if direction != 0:
#					entity.tween_camera_position(entity.default_camera_pos.x * -direction)
#				else:
#					entity.tween_camera_position(start_camera_pos)
#				set_next_state("off_hi_fierce")
#			if key == InputManager.HEAVY:
#				set_next_state("off_kick")
