extends "res://entities/sword_figher/states/sword_fighter_offensive_moves.gd"

#func get_animation_data():
	# Name, seek and blend length 
#	return ["off_h_r_heavy", 0.0, 5.0]
#var direction = 0
var released_up = false

## Initialize state here: Set animation, add impulse, etc.
func _enter_state():
	entity.set_animation("off_run_startup", 0, 10.0)
#	._enter_state()
#
## Inverse of enter_state.
#func _exit_state():
#	if entity.get_current_animation() == "run_loop":
#		entity.tween_camera_position(start_camera_pos)
#	._exit_state()
#	pass
#
#	._process_state(delta)
#	entity.apply_root_motion(delta)
##	pass
#
##func _animation_blend_started(anim_name):
##	print(anim_name)
##	set_next_state("idle")
##	if anim_name == "off_h_r_heavy":
#
func _animation_finished(anim_name):
	if released_up:
#		entity.set_animation("off_run_stop", 0, 10.0)
		set_next_state("offensive_stance")
	else:
		set_next_state("off_run")
#			entity.set_animation("run_loop", 0, -1.0)
#			if entity.input_listener.is_key_pressed(InputManager.RIGHT):
#				direction = 1
#				entity.tween_camera_position(0.0)
#			elif entity.input_listener.is_key_pressed(InputManager.LEFT):
#				direction = -1
#				entity.tween_camera_position(0.0)
				
#	if anim_name == "off_run_stop":
#		set_next_state("offensive_stance")
	

#func _flag_changed(flag, state):
#	if flag == "is_evade_cancelable" and state:
#		if entity.input_listener.is_key_pressed(InputManager.UP):
#			set_next_state("walk")
#		if entity.input_listener.is_key_pressed(InputManager.DOWN):
#			set_next_state("walk")
#		if entity.input_listener.is_key_pressed(InputManager.LEFT):
#			set_next_state("walk")
#		if entity.input_listener.is_key_pressed(InputManager.RIGHT):
#			set_next_state("walk")

func get_possible_transitions():
	return [
		"jump",
		]

func _received_input(key, state):
#	if entity.flags.is_stringable:
	._received_input(key, state)
	
	if not state:
		if key == InputManager.UP:
			released_up = true
			entity.set_animation("off_run_stop", 0, 10.0)
				
#				if direction != 0:
#					entity.tween_camera_position(entity.default_camera_pos.x * -direction)
#				else:
#					entity.tween_camera_position(start_camera_pos)
#				set_next_state("off_hi_fierce")
#			if key == InputManager.HEAVY:
#				set_next_state("off_kick")
