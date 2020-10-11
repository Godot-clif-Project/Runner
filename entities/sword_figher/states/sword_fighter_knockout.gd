extends "res://entities/sword_figher/states/sword_fighter_state.gd"

func get_animation_data():
	# Name, seek and blend length 
	return ["knocked_down", 0.0, 10.0]

# Initialize state here: Set animation, add impulse, etc.
#func _enter_state():
#	entity.get_node("ModelContainer/Particles2").emitting = false
#	._enter_state()

# Inverse of enter_state.
func _exit_state():
	entity.hp = entity.max_hp * 0.25
	._exit_state()
#	pass

#func _animation_finished(anim_name):
#	if anim_name == "stance_off_to_def":
#		set_next_state("defensive_stance")
#	._animation_finished(anim_name)

func _process_state(delta):
#	entity.apply_root_motion(delta)
#	if entity.flags.track_target:
#		entity.apply_tracking(delta)
	entity.hp += 150 * delta
	if entity.hp == entity.max_hp:
		set_next_state("offensive_stance")
		return
		
	entity.apply_drag(delta)
	entity.apply_gravity(delta)
	entity.apply_velocity(delta)
	
	
#	._process_state(delta)

func _received_input(key, state):
	pass
#	print(entity.flags.is_stringable)
#	if entity.get_current_animation() != "stance_off_to_def":
#	._received_input(key, state)
		
#		if state:
#			if key == InputManager.LIGHT:
#				set_next_state("off_hi_light")
#			elif key == InputManager.HEAVY:
#				set_next_state("off_hi_heavy")
#			elif key == InputManager.BREAK:
#				entity.set_animation("stance_off_to_def", 0, 3.0)
#			elif key == InputManager.RUN:
#				if entity.input_listener.is_key_pressed(InputManager.RUN):
#					set_next_state("off_kick")
#				else:
#					set_next_state("off_block")