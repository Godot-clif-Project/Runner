extends "res://entities/sword_figher/states/sword_fighter_state.gd"

func get_animation_data():
	# Name, seek and blend length 
	return ["run_break_loop", 0.0, 16.0]

## Initialize state here: Set animation, add impulse, etc.
func _enter_state():
	entity.velocity = Vector3.ZERO
##	entity.set_animation("off_hi_r_light", 0, 16.0)
#	entity.on_ground = false
#	entity.get_normal()
#	entity.model_container.rotation_degrees.y = entity.arrow.rotation_degrees.y + 180
	
	entity.model_container.rotation.y = entity.get_normal().y + PI
	entity.emit_signal("rotation_changed", entity.model_container.rotation.y)
	._enter_state()
#
## Inverse of enter_state.
##func _exit_state():
##	pass

func _process_state(delta):
#	if entity.ledge_detect_l.get_overlapping_bodies().size() != 0:
##		if entity.ledge_detect_r.get_overlapping_bodies().size() != 0:
##			pass
##		else:
#		entity.model_container.rotation_degrees.y += delta * 180
#	elif entity.ledge_detect_r.get_overlapping_bodies().size() != 0:
##		if entity.ledge_detect_l.get_overlapping_bodies().size() != 0:
##			pass
##		else:
#		entity.model_container.rotation_degrees.y -= delta * 180
	
	if entity.ledge_detect_low.get_overlapping_bodies().size() == 0:
		if entity.input_listener.is_key_pressed(InputManager.UP):
			entity.jump_str = 20
			set_next_state("jump")
#			entity.velocity.y = 10
#			entity.set_velocity(Vector3(0.0, 30.0, -10.0))
		else:
			entity.velocity.y = 0
	else:
		entity.velocity.y = 5
	pass
	
#	entity.apply_drag(delta)
#	entity.center_camera(delta)

#func _touched_surface(surface):
#	if surface == "floor": #and entity.flags.is_active:
#		entity.on_ground = true
##		print(falling_speed)
#		if falling_speed < -22:
#			entity.set_animation("jump_land", 0.0, 16.0)
#		elif entity.input_listener.is_key_pressed(InputManager.UP):
#			set_next_state("off_run")
#		else:
#			set_next_state("offensive_stance")
			

#func _process_state(delta):
#	entity.apply_root_motion(delta)
##	pass
#
##func _animation_blend_started(anim_name):
##	print(anim_name)
##	set_next_state("idle")
##	if anim_name == "off_h_r_heavy":
#
#func _animation_finished(anim_name):
#	if anim_name == "jump_land":
#		if entity.input_listener.is_key_pressed(InputManager.UP):
#			set_next_state("off_run")
#		else:
#			set_next_state("offensive_stance")
#	._animation_finished(anim_name)
#	set_next_state("offensive_stance")
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
