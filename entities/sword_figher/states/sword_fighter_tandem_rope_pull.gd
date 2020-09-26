extends "res://entities/sword_figher/states/sword_fighter_offensive_moves.gd"

func get_animation_data():
	# Name, seek and blend length 
	return ["def_taunt", 0.0, 16.0]

## Initialize state here: Set animation, add impulse, etc.
func _enter_state():
#	if entity.has_los_to_target(entity.lock_on_target):
	var vector_to_target = entity.translation.direction_to(entity.lock_on_target.translation)
	entity.model_container.rotation.y = atan2(vector_to_target.x, vector_to_target.z) + PI
	entity.lock_on_target.receive_tandem_action("rope_pull", entity)
	entity.play_rope_animation(entity.lock_on_target.rope_point.global_transform.origin)
	entity.emit_signal("dealt_tandem_action", "rope_pull", [entity.lock_on_target.rope_point.global_transform.origin])

	._enter_state()
#
## Inverse of enter_state.
##func _exit_state():
##	pass
#
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
#	._animation_finished(anim_name)
#	set_next_state("offensive_stance")
#	pass
#
#func _flag_changed(flag, state):
#	if flag == "is_evade_cancelable" and state:
#		if entity.input_listener.is_key_pressed(InputManager.RUN):
#			set_next_state("walk")
#		if entity.input_listener.is_key_pressed(InputManager.DOWN):
#			set_next_state("walk")
#		if entity.input_listener.is_key_pressed(InputManager.LEFT):
#			set_next_state("walk")
#		if entity.input_listener.is_key_pressed(InputManager.RIGHT):
#			set_next_state("walk")
#
#func _received_input(key, state):
#	if entity.flags.is_stringable:
#		if state:
#			if key == InputManager.LIGHT:
#				set_next_state("off_hi_fierce")
#			if key == InputManager.HEAVY:
#				set_next_state("off_kick")