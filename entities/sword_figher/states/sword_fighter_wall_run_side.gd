extends "res://entities/sword_figher/states/sword_fighter_offensive_moves.gd"

#func get_animation_data():
	# Name, seek and blend length 
#	return ["off_h_r_heavy", 0.0, 5.0]

var t = 0.0
var speed = 0.0
var speed_y = 3.0
var wait = 1

## Initialize state here: Set animation, add impulse, etc.
func _enter_state():
	speed = entity.horizontal_speed
	if speed < 12:
		speed = 12
	if entity.velocity.y > 0.0:
		speed_y = entity.velocity.y * 0.5
	
	entity.raycast_side_high[entity.wall_side].enabled = true
	
	entity.raycast_side[entity.wall_side].cast_to.y = -1.5
	entity.wall_rot = entity.get_normal_side(entity.wall_side)
	entity.set_velocity(Vector3(0.0, speed_y, -speed).rotated(Vector3.RIGHT, entity.wall_rot.x))
	entity.set_animation("run_loop", 0, 10.0)
	entity.has_wall_run_side = false
#	entity.model_container.rotation.y = entity.wall_rot.y - PI
#	if entity.horizontal_speed > target_speed:
#		entity.velocity = entity.velocity.normalized() * target_speed
	
#	._enter_state()
#
## Inverse of enter_state.
func _exit_state():
#	entity.model_container.rotation.y = entity.wall_rot.y + (PI * 0.5) *  -entity.wall_side
	entity.model_container.rotation.z = 0.0
	entity.raycast_side[entity.wall_side].cast_to.y = -0.75
	entity.raycast_side_high[entity.wall_side].enabled = false
#	entity.model.rotation.x = 0.0
#	entity.model.rotation.y = PI
	._exit_state()
#
func _process_state(delta):
	if wait <= 0:
		if not entity.raycast_side[entity.wall_side].is_colliding(): #or not entity.ledge_detect_low.is_colliding():
			set_next_state("fall")
			return
		
		if entity.has_wall_run and entity.ledge_detect_low.is_colliding():
			set_next_state("wall_run")
			return
		
		if not entity.ledge_detect_high.is_colliding() and entity.ledge_detect_low.is_colliding():
			set_next_state("ledge_climb")
			return
		
		if not entity.raycast_side_high[entity.wall_side].is_colliding():
			entity.model_container.rotation.y = entity.wall_rot.y - PI
			entity.velocity = Vector3.ZERO
			set_next_state("ledge_climb")
			return
			
	
	if entity.feet.get_overlapping_bodies().size() != 0:
		entity.has_wall_run_side = true
		set_next_state("run_stop")
		return
	
#	if entity.horizontal_speed < 8.0 or not entity.raycast_side[entity.wall_side].is_colliding():
		
	speed -= delta * 4
	speed_y -= delta * 8
		
	entity.wall_rot = entity.get_normal_side(entity.wall_side)
	entity.set_velocity(Vector3(0.0, speed_y, -speed).rotated(Vector3.RIGHT, entity.wall_rot.x))
	entity.model_container.rotation.y = entity.wall_rot.y - PI * 0.5 * entity.wall_side
	entity.model.rotation.z = PI * -0.2 * entity.wall_side
	
#	entity.model_container.rotation.y = entity.wall_rot.y + PI
#	entity.model.rotation_degrees.y = rad2deg(entity.wall_rot.y + PI * 0.5 * entity.wall_side)
#	prints(entity.wall_rot, entity.model.rotation.y)
	
#	entity.set_velocity(Vector3(speed * -entity.wall_side, speed_y, 0.0).rotated(Vector3.RIGHT, entity.wall_rot.x))
	
	wait -= 1
#		entity.set_velocity(Vector3(0.0, 10, -10).rotated(Vector3.RIGHT, entity.wall_rot.x).rotated(Vector3.FORWARD, PI *entity.input_listener.sticks[0]))
#		entity.model_container.rotation.z = PI * -entity.input_listener.sticks[0]
#		entity.model.rotation.x = entity.wall_rot.x - PI * 0.5
#			entity.velocity.y = 10
#		entity.apply_drag(delta)
#		entity.apply_gravity(delta)
		
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
	if key == InputManager.GUARD:
		if not state:
			if entity.input_listener.is_key_pressed(InputManager.LEFT) and entity.wall_side == 1:
				entity.set_velocity(Vector3(-5, 0.0, 0.0).rotated(Vector3.RIGHT, entity.wall_rot.x))
				entity.model_container.rotation.y = entity.wall_rot.y
			else:
				if entity.input_listener.is_key_pressed(InputManager.RIGHT) and entity.wall_side == -1:
					entity.set_velocity(Vector3(5, 0.0, 0.0).rotated(Vector3.RIGHT, entity.wall_rot.x))
					entity.model_container.rotation.y = entity.wall_rot.y
					
				
				
			set_next_state("jump")
			return
	if state:
		if key == InputManager.DOWN:
			set_next_state("fall")
			return
			
		if entity.has_wall_run:
			if key == InputManager.RIGHT and entity.wall_side == 1:
					entity.model_container.rotation.y = entity.wall_rot.y + PI
					set_next_state("fall")
					return
			
			elif key == InputManager.LEFT and entity.wall_side == -1:
					entity.model_container.rotation.y = entity.wall_rot.y - PI
					set_next_state("fall")
					return
#				entity.model_container.rotation.y = entity.wall_rot.y + PI
#				set_next_state("fall")
#				return

		
	._received_input(key, state)
