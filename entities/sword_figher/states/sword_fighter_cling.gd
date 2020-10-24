extends "res://entities/sword_figher/states/sword_fighter_fall.gd"

var offset : Vector3
var cling_normal : Vector3
var input_dir : Vector3
#var cling_position : Vector3

func get_animation_data():
	# Name, seek and blend length 
	return ["run_break", 0.0, 0.05]

## Initialize state here: Set animation, add impulse, etc.
func _enter_state():
	entity.velocity = Vector3.ZERO
	entity.clinging_to_entity = entity.clingbox.get_overlapping_bodies()[0]
	var dir = entity.translation.direction_to(entity.clinging_to_entity.translation)
	entity.model_container.rotation.y = atan2(dir.x, dir.z) + PI
	
#	print(entity.translation - entity.model_container.transform.basis.z)
	var result = entity.get_world().direct_space_state.intersect_ray(
		entity.translation + entity.model_container.transform.basis.z * 5,
		entity.clinging_to_entity.translation,
		[], 0b00000000000000010000, true, true
		)
	if not result.empty():
#		entity.model_container.rotation.y = atan2(dir.z, dir.x)
		cling_normal = result.normal
		entity.model.look_at(entity.translation + cling_normal, Vector3.UP)
		entity.translation = result.position + cling_normal * 0.5
#		offset = result.position - entity.clinging_to_entity.translation
	else:
		set_next_state("fall")
		return
	
	entity.add_collision_exception_with(entity.clinging_to_entity)
	._enter_state()
#
## Inverse of enter_state.
func _exit_state():
	entity.remove_collision_exception_with(entity.clinging_to_entity)
	entity.model.rotation = Vector3(0, PI, 0)
	._exit_state()
##	pass

func _process_state(delta):
	if entity.input_listener.is_key_pressed(InputManager.RIGHT):
		input_dir = -entity.model.global_transform.basis.x
	elif entity.input_listener.is_key_pressed(InputManager.LEFT):
		input_dir = entity.model.global_transform.basis.x
	elif entity.input_listener.is_key_pressed(InputManager.UP):
		input_dir = entity.model.global_transform.basis.y
	elif entity.input_listener.is_key_pressed(InputManager.DOWN):
		input_dir = -entity.model.global_transform.basis.y
	else:
		input_dir = Vector3.ZERO
		
	if input_dir != Vector3.ZERO:
		var result = entity.get_world().direct_space_state.intersect_ray(
#		entity.translation + entity.model.transform.xform(-Vector3(input_dir.x, input_dir.y, 0.0)) * 0.1,
		entity.translation + input_dir * 0.1,
#		entity.translation + entity.model.transform.xform(-Vector3(dir.x, dir.y, -1.0)) * 0.1,
		entity.clinging_to_entity.translation,
		[], 0b00000000000000010000, true, true
		)
		if not result.empty():
			cling_normal = result.normal
			entity.model.look_at(entity.translation + cling_normal, Vector3.UP)
			entity.translation = result.position + cling_normal * 0.5
		
	entity.velocity = entity.clinging_to_entity.velocity
	entity.apply_velocity(delta)
	pass

func get_possible_transitions():
	return [
		"jump",
#		"air_boost",
		]

func _touched_surface(surface):
	set_next_state("fall")
	return
#	if surface == "floor": #and entity.flags.is_active:
#		entity.velocity = Vector3.ZERO
#		set_next_state("land")
#		entity.on_ground = true
##		print(falling_speed)
#		if falling_speed < -22:
#			entity.set_animation("jump_land", 0.0, 16.0)
#		elif entity.input_listener.is_key_pressed(InputManager.RUN):
#			set_next_state("run")
#		else:
#			set_next_state("offensive_stance")
			

##func _animation_blend_started(anim_name):
##	print(anim_name)
##	set_next_state("idle")
##	if anim_name == "off_h_r_heavy":
#
#func _animation_finished(anim_name):
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

func _received_input(key, state):
#	if state:
#		if key == InputManager.UP:
#			input_dir = entity.model.global_transform.basis.y * 0.1
#		if key == InputManager.DOWN:
#			input_dir = -entity.model.global_transform.basis.y * 0.1
#		if key == InputManager.RIGHT:
#			input_dir = -entity.model.global_transform.basis.x * 0.1
#		if key == InputManager.LEFT:
#			input_dir = entity.model.global_transform.basis.x * 0.1
		
#	if key == InputManager.UP or key == InputManager.DOWN or key == InputManager.RIGHT or key == InputManager.LEFT:
#		if state:
#			input_dir += InputManager.KEY_TO_DIRECTIONS[key]
#		else:
#			input_dir -= InputManager.KEY_TO_DIRECTIONS[key]
#	else:
		._received_input(key, state)
