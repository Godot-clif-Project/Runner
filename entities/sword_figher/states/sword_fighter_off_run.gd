extends "res://entities/sword_figher/states/sword_fighter_offensive_moves.gd"

#func get_animation_data():
	# Name, seek and blend length 
#	return ["off_h_r_heavy", 0.0, 5.0]
#var direction = 0
var released_up = false
var ang_momentum = 0.0
var rot_drag = 6
var rot_speed = 30
var max_turn_speed = 3

## Initialize state here: Set animation, add impulse, etc.
func _enter_state():
	entity.set_animation("run_loop", 0, 10.0)
#	._enter_state()
#
## Inverse of enter_state.
func _exit_state():
	entity.model.rotation.z = 0.0
#	if entity.get_current_animation() == "run_loop":
#		entity.tween_camera_position(start_camera_pos)
	._exit_state()
#	pass
#
func _process_state(delta):
#	if not entity.is_on_floor():
#	print(entity.feet.get_overlapping_bodies())
	if entity.feet.get_overlapping_bodies().size() == 0:
		set_next_state("fall")
		return
	
	if entity.flags.is_active:
#		entity.set_velocity(Vector3(0.0, 0.0, -13.0))
		entity.set_target_velocity(Vector3(0.0, 0.0, -13.0))
		entity.lerp_velocity(delta)
	else:
		entity.apply_drag(delta)
#		if entity.velocity.length_squared() < 0.05:
#			set_next_state("offensive_stance")
	var stick = entity.input_listener.sticks[0]
	if abs(stick) > 0.1:
		ang_momentum = clamp(-stick * max_turn_speed, -max_turn_speed, max_turn_speed)
	
	if entity.input_listener.is_key_pressed(InputManager.RIGHT):
		ang_momentum = clamp(ang_momentum - delta * rot_speed, -max_turn_speed, max_turn_speed)
#
	elif entity.input_listener.is_key_pressed(InputManager.LEFT):
		ang_momentum = clamp(ang_momentum + delta * rot_speed, -max_turn_speed, max_turn_speed) 
		
	else:
		ang_momentum = lerp(ang_momentum, 0, delta * rot_drag)
	
#	entity.model.rotation_degrees.z = ang_momentum * -7
	entity.model_container.rotation_degrees.y += ang_momentum
	entity.center_camera(delta)
	
		
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
	if anim_name == "off_run_startup":
		if released_up:
			entity.set_animation("off_run_stop", 0, 10.0)
		else:
			entity.set_animation("run_loop", 0, -1.0)
#			if entity.input_listener.is_key_pressed(InputManager.RIGHT):
#				direction = 1
#				entity.tween_camera_position(0.0)
#			elif entity.input_listener.is_key_pressed(InputManager.LEFT):
#				direction = -1
#				entity.tween_camera_position(0.0)
				
	elif anim_name == "off_run_stop":
		set_next_state("offensive_stance")
	

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
	._received_input(key, state)
	if not state:
		if key == InputManager.UP:
			released_up = true
			if entity.get_current_animation() == "run_loop":
				entity.set_animation("off_run_stop", 0, 10.0)
