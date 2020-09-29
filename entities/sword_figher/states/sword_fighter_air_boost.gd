extends "res://entities/sword_figher/states/sword_fighter_fall.gd"

func get_animation_data():
	# Name, seek and blend length 
	return ["air_boost", 0.0, 16.0]

## Initialize state here: Set animation, add impulse, etc.
func _enter_state():
	entity.velocity *= 0.6
##	entity.set_animation("off_hi_r_light", 0, 16.0)
#	entity.on_ground = false
	._enter_state()
#
## Inverse of enter_state.
##func _exit_state():
##	pass

#func _process_state(delta):
#	pass
#	._process_state(delta)
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
#			var stick = entity.input_listener.sticks[0]
#			if abs(stick) > 0.1:
#				entity.model_container.rotation_degrees.y -= stick * delta * 270
#
#	if entity.velocity.y < falling_speed:
#		falling_speed = entity.velocity.y
#
#	entity.apply_drag(delta)
#	entity.center_camera(delta)

#func _touched_surface(surface):

#func _process_state(delta):
#	entity.apply_root_motion(delta)
##	pass

#func _animation_finished(anim_name):
#	._animation_finished(anim_name)
#
#	set_next_state("fall")
#	pass
#
func _flag_changed(flag, state):
	if flag == "is_active":
#		var strength = clamp(entity.jump_str
		entity.set_velocity(Vector3(0.0, entity.jump_str * 0.5 , -entity.jump_str * 0.6))

#func _received_input(key, state):
#	pass
#	if entity.on_ground:
#		._received_input(key, state)
		
#	if entity.flags.is_stringable:
#		if state:
#			if key == InputManager.LIGHT:
#				set_next_state("off_hi_fierce")
#			if key == InputManager.HEAVY:
#				set_next_state("off_kick")
