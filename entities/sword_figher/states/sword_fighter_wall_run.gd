extends "res://entities/sword_figher/states/sword_fighter_offensive_moves.gd"

#func get_animation_data():
	# Name, seek and blend length 
#	return ["off_h_r_heavy", 0.0, 5.0]

var released_up = false
var ang_momentum = 0.0
var rot_drag = 15
var rot_speed = 30
var max_turn_speed = 3.2
var target_speed = 13.0
var acceleration = 1.0

var turn_acc = 0.0
var current_turn_dir = 0
var prev_turn_dir = 0

var wall_rot
var t = 0.0

## Initialize state here: Set animation, add impulse, etc.
func _enter_state():
	entity.velocity = Vector3.ZERO
	entity.set_animation("run_loop", 0, 10.0)
#	wall_rot = entity.get_normal()
#	entity.model_container.rotation.y = wall_rot.y - PI
	entity.has_wall_run = false
#	if entity.horizontal_speed > target_speed:
#		entity.velocity = entity.velocity.normalized() * target_speed
	
#	print(entity.get_normal())
#	._enter_state()
#
## Inverse of enter_state.
func _exit_state():
	entity.model.rotation.x = 0.0
	entity.model_container.rotation.z = 0.0
	._exit_state()
#
func _process_state(delta):
	if t > 0.6:
#		entity.model_container.rotation.y = wall_rot.y
#		entity.set_velocity(Vector3(0.0, 0.0, -10))
		entity.jump_str = 20
		set_next_state("jump")
		return
	else:
		t += delta
	
		if entity.ledge_detect_low.get_overlapping_bodies().size() == 0:
	#		if entity.input_listener.is_key_pressed(InputManager.UP):
			entity.jump_str = 20
			set_next_state("jump")
			return
	#		else:
	#			entity.velocity.y = 0
		else:
#			entity.input_listener.sticks[0]
			
			wall_rot = entity.get_normal()
#			entity.set_velocity(Vector3(0.0, 10, -10).rotated(Vector3.RIGHT, wall_rot.x).rotated(Vector3.FORWARD, PI *entity.input_listener.sticks[0]))
#			entity.model_container.rotation.z = PI * -entity.input_listener.sticks[0]
			entity.set_velocity(Vector3(0.0, 10, -10).rotated(Vector3.RIGHT, wall_rot.x))
			entity.model.rotation.x = wall_rot.x - PI * 0.5
			entity.model_container.rotation.y = wall_rot.y - PI
#			entity.velocity.y = 10
		
##func _animation_blend_started(anim_name):
##	print(anim_name)
##	set_next_state("idle")
##	if anim_name == "off_h_r_heavy":
#
func _animation_finished(anim_name):
	pass
#	if anim_name == "off_run_startup":
#		if entity.input_listener.is_key_released(InputManager.UP):
#			set_next_state("offensive_stance")
#		else:
#			entity.set_animation("run_loop", 0, -1.0)
			

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
	if not state:
		if key == InputManager.GUARD:
			entity.velocity = Vector3.ZERO
			entity.model_container.rotation.y = wall_rot.y
#		if key == InputManager.DOWN:
#			set_next_state("run_stop")
#			return
#		if key == InputManager.UP_UP:
#			target_speed = 23
#			max_turn_speed = 2.3
##			entity.set_velocity(Vector3(0.0, 0.0, -target_speed))
##			acceleration = 2.0
#			entity.emit_one_shot()
#			if target_speed < 22:
#				target_speed += 6
#			else:
#				target_speed = 22
				
#			released_up = true
#			if entity.get_current_animation() == "run_loop":
#				entity.set_animation("off_run_stop", 0, 10.0)
#			set_next_state("run_stop")
#			return
#	else:
#		if key == InputManager.UP:
##			set_next_state("run_stop")
#			target_speed -= delta
#			print("ASD")
#			return
		
	._received_input(key, state)
