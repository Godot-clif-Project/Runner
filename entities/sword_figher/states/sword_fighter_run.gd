extends "res://entities/sword_figher/states/sword_fighter_offensive_moves.gd"

#func get_animation_data():
	# Name, seek and blend length 
#	return ["off_h_r_heavy", 0.0, 5.0]

var released_up = false
var ang_momentum = 0.0
var rot_lerp = 4.0
var max_turn_speed = 4.5
var rot_speed = 30

var boost_charge = 0.0

var turn_acc = 0.0
var current_turn_dir = 0
var prev_turn_dir = 0

## Initialize state here: Set animation, add impulse, etc.
func _enter_state():
	entity.set_animation("run_loop_c", 0, 0.05)
#	if entity.horizontal_speed > entity.target_speed:
#		entity.velocity = entity.velocity.normalized() * entity.target_speed
	entity.model.rotation.z = 0.0
	entity.get_node("ModelContainer/Particles2").emitting = true
#	entity.velocity = entity.velocity.rotated(Vector3.UP, entity.model_container.rotation.y)
#	entity.accelerate(-entity.target_speed, 0.01)
#	._enter_state()
#
## Inverse of enter_state.
func _exit_state():
	entity.set_collision_mask_bit(0, true)
	entity.anim_tree["parameters/TimeScale/scale"] = 1
	._exit_state()

var t = 0.0
var t_2 = 0.0
func _process_state(delta):
		
	if entity.feet.get_overlapping_bodies().size() == 0:
		set_next_state("fall")
		return
		
	# Small ledge:
#	if t <= 0.0:
#		if entity.feet.get_overlapping_bodies().size() == 0:
#			t_2 -= delta
#			if t_2 <= 0.0:
#				set_next_state("fall")
#				return
#		else:
#			t_2 = 0.1
#		if entity.raycast.is_colliding():
#			if not entity.ledge_detect_high.is_colliding():
#				entity.set_collision_mask_bit(0, false)
#				t = 0.08
#	else:
#		entity.translate(Vector3(0.0, 15 * delta, 0.0))
#		t -= delta
#		if t <= 0.0 and not entity.get_collision_mask_bit(0):
##			entity.set_collision_layer_bit(2, true)
#			entity.set_collision_mask_bit(0, true)
		
#	var stick = entity.input_listener.analogs[0]
#		turn = -stick
#		ang_momentum = clamp(ang_momentum + delta * rot_speed * -stick * 0.5, -max_turn_speed, max_turn_speed)
#		ang_momentum = clamp(-stick * max_turn_speed, -max_turn_speed, max_turn_speed)
#		ang_momentum = lerp(ang_momentum, -stick * max_turn_speed, delta * rot_lerp)
#		pass
	if abs(entity.input_listener.analogs[0]) == 0.0:
		if entity.input_listener.is_key_pressed(InputManager.RIGHT):
			current_turn_dir = 1
			turn_acc = lerp(turn_acc, 1, delta * 5)
			ang_momentum = clamp(ang_momentum - delta * rot_speed * turn_acc, -max_turn_speed, max_turn_speed)
		elif entity.input_listener.is_key_pressed(InputManager.LEFT):
			current_turn_dir = -1
			turn_acc = lerp(turn_acc, 1, delta * 5)
			ang_momentum = clamp(ang_momentum + delta * rot_speed * turn_acc, -max_turn_speed, max_turn_speed) 
		else:
			current_turn_dir = 0
	#		turn = lerp(turn, 0, delta * 4)
	#		ang_momentum = lerp(ang_momentum, 0, delta * rot_lerp)
	#		var n = entity.velocity.normalized()
	#		entity.model_container.rotation.y = lerp_angle(entity.model_container.rotation.y, atan2(n.z, n.x), delta * 4)

	ang_momentum = lerp(ang_momentum, -entity.input_listener.analogs[0] * max_turn_speed * (1 - (entity.target_speed / entity.boost_speed) * 0.5), delta * rot_lerp)
#	ang_momentum = lerp(ang_momentum, -stick * max_turn_speed, delta * rot_lerp)
	
	if current_turn_dir != prev_turn_dir:
		turn_acc = 0.0
		prev_turn_dir = current_turn_dir
	
#	if entity.input_listener.is_key_released(InputManager.RUN) and entity.input_listener.is_key_released(InputManager.UP):
#	if entity.input_listener.analogs[7] == 0.0 and entity.input_listener.is_key_released(InputManager.UP):
#	if entity.input_listener.get_analog_trigger(7) < 0.05 and entity.input_listener.is_key_released(InputManager.UP):
#		entity.target_speed -= delta * 8
#	print(entity.target_speed)
	
	if entity.target_speed > entity.max_speed:
#		entity.target_speed -= delta * 50
		entity.target_speed = lerp(entity.target_speed, entity.min_speed, delta * 3)
	else:
		if entity.input_listener.is_key_pressed(InputManager.UP):
			entity.target_speed = lerp(entity.target_speed, entity.max_speed, delta * 2)
		else:
			if entity.target_speed > entity.max_speed * entity.input_listener.analogs[7]:
				entity.target_speed = lerp(entity.target_speed, entity.max_speed * entity.input_listener.analogs[7], delta * 0.5)
			else:
				entity.target_speed = lerp(entity.target_speed, entity.max_speed * entity.input_listener.analogs[7], delta * 2)
	
		if entity.target_speed < entity.min_speed:
			set_next_state("run_stop")
			return
	
	
	# slow down whent turning
#	entity.target_speed *= 1 - abs(ang_momentum) / (max_turn_speed * 6)
	
	# rotate character freely
	entity.model_container.rotation_degrees.y += ang_momentum
	# + turn speed dependant on velocity
#	entity.model_container.rotation_degrees.y += ang_momentum * float(1 - entity.target_speed / entity.boost_speed * 0.5)
	
	# rotate character dependant on velocity
#	var vel_angle = atan2(entity.velocity.x, entity.velocity.z)
#	entity.model_container.rotation.y = vel_angle + PI + ang_momentum * 0.25
	
	entity.acceleration = clamp(entity.acceleration + delta, 0, 1.0)
	entity.accelerate(-entity.target_speed, delta * entity.acceleration * 5)
	entity.apply_gravity(delta)
	entity.apply_velocity(delta)
	
	entity.anim_tree["parameters/TimeScale/scale"] = float(entity.target_speed / entity.boost_speed * 0.25) + 1.0
	entity.center_camera(delta)
	entity.emit_signal("rotation_changed", entity.model_container.rotation.y)
	
#	entity.translation = Vector3.ZERO

func _touched_surface(surface):
	if surface == "wall":
		if entity.prev_speed > 10:
			var wall_normal = entity.get_slide_collision(0).normal
			var wall_position = entity.get_slide_collision(0).position
			var player_vector = -entity.model_container.transform.basis.z
			var rot = Vector2(player_vector.x, player_vector.z).angle_to(Vector2(wall_normal.x, wall_normal.z))
			
			entity.velocity *= 1 - abs(wall_normal.dot(player_vector) * 1.0)
	#			if entity.target_speed <= entity.max_speed:
	#	#			entity.model_container.rotation.y -= (PI * 0.333) * (entity.prev_speed * 0.1) * abs(wall_normal.dot(player_vector)) * sign(rot)
	#				entity.velocity += wall_normal * entity.prev_speed * 0.25
	#			else:
	#	#			entity.model_container.rotation.y -= (PI * 0.5) * (entity.prev_speed * 0.1) * abs(wall_normal.dot(player_vector)) * sign(rot)
	#				entity.velocity += wall_normal * entity.prev_speed * 0.33
				
			entity.velocity += wall_normal * entity.prev_speed * 0.33
			entity.acceleration = 0.0
			
			var _hit = Hit.new(Hit.INIT_TYPE.WALL)
			_hit.position = wall_position
			_hit.damage = entity.prev_speed * 2
			entity._receive_hit(_hit)

			if rot > 0.0:
				entity.set_animation("run_bump_l", 0.0, 0.05)
			else:
				entity.set_animation("run_bump_r", 0.0, 0.05)
	

func _animation_finished(anim_name):
	if anim_name == "run_bump_l" or anim_name == "run_bump_r":
		entity.set_animation("run_loop_c", 0, 0.25)
	pass
#	if anim_name == "off_run_startup":
#		if entity.input_listener.is_key_released(InputManager.RUN):
#			set_next_state("offensive_stance")
#		else:
#			entity.set_animation("run_loop", 0, -1.0)
			

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

func get_possible_transitions():
	return [
		"tandem_rope_pull",
		"tandem_launch_up",
		"jump",
		"sidestep",
		"slide",
		"air_atk",
		]

func _received_input(key, state):
	if state:
		if key == InputManager.BREAK:
			set_next_state("run_stop")
			return
		if key == InputManager.RUN_RUN or key == InputManager.UP_UP:
			if entity.target_speed <= entity.max_speed:
				entity.target_speed = entity.boost_speed
				entity.acceleration = 0.85
#	else:
#		if key == InputManager.FIRE:
#			if entity.target_speed <= entity.max_speed:
#				entity.target_speed = entity.boost_speed * boost_charge
#				entity.acceleration = 0.25
#			max_turn_speed = 2.3
#			entity.set_velocity(Vector3(0.0, 0.0, -entity.target_speed))
#			acceleration = 2.0
#			entity.emit_one_shot("ParticlesBoost")
#			if entity.target_speed < 22:
#				entity.target_speed += 6
#			else:
#				entity.target_speed = 22
				
#			released_up = true
#			if entity.get_current_animation() == "run_loop":
#				entity.set_animation("off_run_stop", 0, 10.0)
#			set_next_state("run_stop")
#			return
#	else:
#		if key == :
##			set_next_state("run_stop")
#			entity.target_speed -= delta
#			print("ASD")
#			return
		
	._received_input(key, state)
