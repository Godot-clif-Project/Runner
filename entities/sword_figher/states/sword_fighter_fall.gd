extends "res://entities/sword_figher/states/sword_fighter_offensive_moves.gd"

var falling_speed = 0.0

func get_animation_data():
	# Name, seek and blend length 
	return ["run_break", 0.0, 16.0]

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
	if entity.get_current_animation() == "jump_land":
#		entity.apply_rotation(delta)
		if entity.input_listener.is_key_pressed(InputManager.RIGHT):
			entity.model_container.rotation_degrees.y -= delta * 270
		
		elif entity.input_listener.is_key_pressed(InputManager.LEFT):
			entity.model_container.rotation_degrees.y += delta * 270
			
		else:
			var stick = entity.input_listener.sticks[0]
			if abs(stick) > 0.1:
				entity.model_container.rotation_degrees.y -= stick * delta * 270
				
		entity.set_velocity(Vector3(0.0, 0.0, -Vector2(entity.velocity.x, entity.velocity.z).length()))
			
	if entity.velocity.y < falling_speed:
		falling_speed = entity.velocity.y
	
	entity.apply_drag(delta)
	entity.center_camera(delta)

func _touched_surface(surface):
	if surface == "floor":
		entity.on_ground = true
#		print(falling_speed)
		if falling_speed < -22:
			entity.set_animation("jump_land", 0.0, 16.0)
			
		elif entity.input_listener.is_key_pressed(InputManager.UP):
			set_next_state("off_run")
			
		else:
			set_next_state("run_stop")
			

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
	if anim_name == "jump_land":
		if entity.input_listener.is_key_pressed(InputManager.UP):
			set_next_state("off_run")
		else:
			set_next_state("offensive_stance")
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
func _received_input(key, state):
	if entity.on_ground:
		._received_input(key, state)
		
#	if entity.flags.is_stringable:
#		if state:
#			if key == InputManager.LIGHT:
#				set_next_state("off_hi_fierce")
#			if key == InputManager.HEAVY:
#				set_next_state("off_kick")
