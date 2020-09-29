extends "res://entities/sword_figher/states/sword_fighter_state.gd"

var turn_speed = 180.0
#var falling_speed = 0.0

func get_animation_data():
	# Name, seek and blend length 
	return ["fall", 0.0, 16.0]

## Initialize state here: Set animation, add impulse, etc.
func _enter_state():
#	entity.set_animation("off_hi_r_light", 0, 16.0)
	entity.on_ground = false
	entity.model.rotation.z = 0.0
	._enter_state()
#
## Inverse of enter_state.
##func _exit_state():
##	pass

func _process_state(delta):
	
	if entity.input_listener.is_key_pressed(InputManager.RIGHT):
		entity.model_container.rotation_degrees.y -= delta * turn_speed
	
	elif entity.input_listener.is_key_pressed(InputManager.LEFT):
		entity.model_container.rotation_degrees.y += delta * turn_speed
		
	else:
		var stick = entity.input_listener.sticks[0]
		if abs(stick) > 0.1:
			entity.model_container.rotation_degrees.y -= stick * delta * turn_speed
	
	if entity.input_listener.is_key_pressed(InputManager.FIRE):
		if entity.ledge_detect_low.is_colliding():
			if entity.ledge_detect_low.get_collider().is_in_group("ledge"):
				if not entity.ledge_detect_high.is_colliding():
					set_next_state("ledge_climb")
					return
#
#		if entity.has_wall_run:
#			if entity.raycast.is_colliding():
#				set_next_state("wall_run")
#				return
#
#		if entity.has_wall_run_side:
#			if entity.raycast_side[-1].is_colliding():
#				entity.wall_side = -1
#				set_next_state("wall_run_side")
#				return
#
#			if entity.raycast_side[1].is_colliding():
#				entity.wall_side = 1
#				set_next_state("wall_run_side")
#				return
	
	if entity.velocity.y < 0.0:
		entity.falling_speed = entity.velocity.y
	
	entity.apply_drag(delta)
	entity.apply_gravity(delta)
	entity.center_camera(delta)
	
	entity.emit_signal("rotation_changed", entity.model_container.rotation.y)
	
func _touched_surface(surface):
	if surface == "floor":
		set_next_state("land")

#func _process_state(delta):
#	entity.apply_root_motion(delta)
##	pass
#
##func _animation_blend_started(anim_name):
##	print(anim_name)
##	set_next_state("idle")
##	if anim_name == "off_h_r_heavy":
#
func _animation_finished(anim_name):
	pass

#	set_next_state("offensive_stance")
#	._animation_finished(anim_name)
#	pass
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

func get_possible_transitions():
	return [
		"air_boost",
#		"jump",
		"tandem_rope_pull",
		"tandem_launch_up",
		]

func _received_input(key, state):
	if state:
		if key == InputManager.FIRE:
#			if entity.ledge_detect_low.is_colliding():
#				if entity.ledge_detect_low.get_collider().is_in_group("ledge"):
#					if not entity.ledge_detect_high.is_colliding():
#						set_next_state("ledge_climb")
#						return
					
			if entity.has_wall_run:
				if entity.raycast.is_colliding():
					set_next_state("wall_run")
					return
					
			if entity.has_wall_run_side:
				if entity.raycast_side[-1].is_colliding():
					entity.wall_side = -1
					set_next_state("wall_run_side")
					return
					
				if entity.raycast_side[1].is_colliding():
					entity.wall_side = 1
					set_next_state("wall_run_side")
					return
				
#	if key == InputManager.JUMP:
#		entity.set_velocity(Vector3(0.0, 0.0, -12))
#		entity.jump_str = 15
#		set_next_state("jump")
#			if key == InputManager.HEAVY:

#	if entity.on_ground:
	._received_input(key, state)
