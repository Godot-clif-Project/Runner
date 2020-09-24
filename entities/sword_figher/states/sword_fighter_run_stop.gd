extends "res://entities/sword_figher/states/sword_fighter_offensive_moves.gd"

#func get_animation_data():
	# Name, seek and blend length 
#	return ["off_h_r_heavy", 0.0, 5.0]

var released_up = false
var ang_momentum = 0.0
var rot_drag = 8
var rot_speed = 30
var max_turn_speed = 4.5

var speed = 0.0

## Initialize state here: Set animation, add impulse, etc.
func _enter_state():
	speed = entity.horizontal_speed
	
	entity.set_animation("run_break", 0, 30.0)
	
#	if entity.input_listener.is_key_pressed(InputManager.DOWN):
#		entity.ground_drag = 20
#	else:
#		entity.ground_drag = entity.default_ground_drag
	
#	._enter_state()
#
## Inverse of enter_state.
func _exit_state():
	entity.model.rotation.z = 0.0
	._exit_state()
	
func _process_state(delta):
	if entity.velocity.length_squared() < 1.0 and entity.on_ground:
		set_next_state("offensive_stance")
		return
		
	if entity.feet.get_overlapping_bodies().size() == 0:
		set_next_state("fall")
		return
	
	var stick = entity.input_listener.sticks[0]
	if abs(stick) > 0.1:
		ang_momentum = clamp(-stick * max_turn_speed, -max_turn_speed, max_turn_speed)
	
	elif entity.input_listener.is_key_pressed(InputManager.RIGHT):
		ang_momentum = clamp(ang_momentum - delta * rot_speed, -max_turn_speed, max_turn_speed)
#
	elif entity.input_listener.is_key_pressed(InputManager.LEFT):
		ang_momentum = clamp(ang_momentum + delta * rot_speed, -max_turn_speed, max_turn_speed) 
		
	else:
		ang_momentum = lerp(ang_momentum, 0, delta * rot_drag)
	
	if entity.input_listener.is_key_pressed(InputManager.BREAK):
		entity.ground_drag = 10
	else:
		entity.ground_drag = 5
		
		
	entity.model_container.rotation_degrees.y += ang_momentum
	entity.emit_signal("rotation_changed", entity.model_container.rotation.y)
	
	speed = clamp(speed - delta * entity.ground_drag, 0, 25)
	entity.apply_drag(delta)
	entity.accelerate(-speed, delta * 0.25)
	entity.apply_gravity(delta)
	
	entity.center_camera(delta * 2)
	
#	._process_state(delta)



func _animation_finished(anim_name):
#	if anim_name == "off_run_startup":
#		if released_up:
#			entity.set_animation("off_run_stop", 0, 10.0)
#		else:
#			entity.set_animation("run_loop", 0, -1.0)
#			if entity.input_listener.is_key_pressed(InputManager.RIGHT):
#				direction = 1
#				entity.tween_camera_position(0.0)
#			elif entity.input_listener.is_key_pressed(InputManager.LEFT):
#				direction = -1
#				entity.tween_camera_position(0.0)
				
#	elif anim_name == "off_run_stop":
#	set_next_state("offensive_stance")
	pass
	

func _flag_changed(flag, state):
	pass

func get_possible_transitions():
	return [
		"jump",
		"off_run_startup",
		]

func _received_input(key, state):
	if state:
		if key == InputManager.RUN:
			set_next_state("off_run")
			return
#		if key == InputManager.DOWN:
#			entity.ground_drag = 20
#	else:
#		if key == InputManager.DOWN:
#			entity.ground_drag = entity.default_ground_drag
		
	
	._received_input(key, state)
#	pass
