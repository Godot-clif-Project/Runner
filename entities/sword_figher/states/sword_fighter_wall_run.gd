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

var speed = 20
var wall_rot
var t = 0.0

## Initialize state here: Set animation, add impulse, etc.
func _enter_state():
#	speed += entity.horizontal_speed
#	print(entity.prev_speed)
	entity.velocity = Vector3.ZERO
	wall_rot = entity.get_normal()
	entity.set_animation("run_loop", 0, 10.0)
	entity.has_wall_run = false
#	entity.model_container.rotation.y = wall_rot.y - PI
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
			entity.set_velocity(Vector3(0.0, 10, -2).rotated(Vector3.RIGHT, wall_rot.x))
			set_next_state("jump")
			return
	#		else:
	#			entity.velocity.y = 0
		else:
#			entity.input_listener.sticks[0]
#			entity.set_velocity(Vector3(0.0, 10, -10).rotated(Vector3.RIGHT, wall_rot.x).rotated(Vector3.FORWARD, PI *entity.input_listener.sticks[0]))
#			entity.model_container.rotation.z = PI * -entity.input_listener.sticks[0]
			speed -= delta * 25
			wall_rot = entity.get_normal()
			entity.set_velocity(Vector3(0.0, speed, -10).rotated(Vector3.RIGHT, wall_rot.x))
			entity.model.rotation.x = wall_rot.x - PI * 0.5
			entity.model_container.rotation.y = wall_rot.y - PI
		
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
	._received_input(key, state)
