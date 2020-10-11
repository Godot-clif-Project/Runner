extends "res://entities/sword_figher/states/sword_fighter_fall.gd"

func get_animation_data():
	# Name, seek and blend length 
#	return ["air_atk_l", 0.0, 30.0]
	return null

## Initialize state here: Set animation, add impulse, etc.
func _enter_state():
	entity.velocity.y = 0.0
	entity.model.rotation.z = 0.0
	if entity.input_listener.analogs[0] >= 0.0:
		entity.set_animation("air_atk_r", 0, 30.0)
	else:
		entity.set_animation("air_atk_l", 0, 30.0)
		
#	entity.jump()
#	entity.on_ground = false
	._enter_state()
#
## Inverse of enter_state.
func _exit_state():
	entity.gravity_scale = 1.0
	entity.get_node("ModelContainer/sword_fighter/slash").visible = false
#	entity.get_node("ModelContainer/SlashParticles").visible = false
	entity.get_node("ModelContainer/SlashParticles").emitting = false
	._exit_state()

func _process_state(delta):
	if entity.is_on_wall():
		entity.get_node("ModelContainer/Hitbox").active = false
		entity.get_node("ModelContainer/sword_fighter/slash").visible = false
		entity.get_node("ModelContainer/SlashParticles").visible = false
		entity.get_node("ModelContainer/SlashParticles").emitting = false
	._process_state(delta)
#	if entity.get_current_animation() == "jump_land":
#		entity.set_velocity(Vector3(0.0, 0.0, -Vector2(entity.velocity.x, entity.velocity.z).length()))
##		entity.apply_rotation(delta)
#		if entity.input_listener.is_key_pressed(InputManager.RIGHT):
#			entity.model_container.rotation_degrees.y -= delta * 270
#
#		elif entity.input_listener.is_key_pressed(InputManager.LEFT):
#			entity.model_container.rotation_degrees.y += delta * 270
#
#		else:
#			var stick = entity.input_listener.analogs[0]
#			if abs(stick) > 0.1:
#				entity.model_container.rotation_degrees.y -= stick * delta * 270
#
#	if entity.velocity.y < falling_speed:
#		falling_speed = entity.velocity.y
#
#	entity.apply_drag(delta)
#	entity.center_camera(delta)

#func _touched_surface(surface):
#	set_next_state("fall")
#	return
#	if surface == "floor": #and entity.flags.is_active:
#		entity.on_ground = true
##		print(falling_speed)
#		if falling_speed < -22:
#			entity.set_animation("jump_land", 0.0, 16.0)
#		elif entity.input_listener.is_key_pressed(InputManager.RUN):
#			set_next_state("run")
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
#	set_next_state("fall")
#	return
#	if anim_name == "jump_land":
#		if entity.input_listener.is_key_pressed(InputManager.RUN):
#			set_next_state("run")
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
