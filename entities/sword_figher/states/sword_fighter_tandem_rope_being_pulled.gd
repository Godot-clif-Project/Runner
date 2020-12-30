extends "res://entities/sword_figher/states/sword_fighter_state.gd"

var start_pos
var vector_to_target
var initial_distance_to_target

func get_animation_data():
	# Name, seek and blend length 
	return ["t_pose", 0.0, 0.05]

## Initialize state here: Set animation, add impulse, etc.
func _enter_state():
#	vector_to_target = entity.translation.direction_to(entity.tandem_entity.translation)
#	entity.model_container.rotation.y = atan2(vector_to_target.x, vector_to_target.z) + PI
	initial_distance_to_target = entity.translation.distance_to(entity.tandem_entity.translation)
	entity.on_ground = false
	
#	start_pos = entity.translation
	
#	entity.velocity = (vector_to_target * clamp(distance_to_target * 10, 0, 30))

#	print(distance_to_target)
#		entity.set_velocity(Vector3(0.0, 0.0, -10.0))
#		entity.jump_str = 20
#		set_next_state("jump")

	._enter_state()
#
## Inverse of enter_state.
func _exit_state():
	entity.gravity_scale = 1.0
	._exit_state()
##	pass

var t = 0.0
var t_1 = 0.0
func _process_state(delta):
#	entity.translation = start_pos.linear_interpolate(entity.tandem_entity.translation, t)
	vector_to_target = entity.translation.direction_to(entity.tandem_entity.translation)
	entity.model_container.rotation.y = atan2(vector_to_target.x, vector_to_target.z) + PI
	
	if entity.translation.distance_to(entity.tandem_entity.translation) < 3:
		entity.velocity = (vector_to_target * 10)
		set_next_state("jump")
		return
		
	t_1 += delta
	t = t_1 * t_1 * t_1 * t_1 * t_1
	entity.velocity = (vector_to_target * 1.5 * initial_distance_to_target * (1 - t))
	if t >= 0.8:
		entity.velocity = (vector_to_target * 10)
#		entity.jump_str = 10
		set_next_state("jump")
		return
		
	entity.center_camera(delta * 2, Vector2.ZERO)
	entity.apply_velocity(delta)
#	entity.apply_gravity(delta)
#	entity.apply_drag(delta)
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
