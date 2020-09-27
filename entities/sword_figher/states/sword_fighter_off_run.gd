extends "res://entities/sword_figher/states/sword_fighter_offensive_moves.gd"

#func get_animation_data():
	# Name, seek and blend length 
#	return ["off_h_r_heavy", 0.0, 5.0]

var released_up = false
var ang_momentum = 0.0
var rot_drag = 15
var rot_speed = 30
var max_turn_speed = 3.2
var target_speed = 13.0
var max_speed = 10.0
var boost_speed = 16.0
var acceleration = 1.0

var turn_acc = 0.0
var current_turn_dir = 0
var prev_turn_dir = 0

## Initialize state here: Set animation, add impulse, etc.
func _enter_state():
	entity.set_animation("run_loop", 0, 10.0)
#	if entity.horizontal_speed > target_speed:
#		entity.velocity = entity.velocity.normalized() * target_speed
		
	entity.model.rotation.z = 0.0
	entity.get_node("ModelContainer/Particles2").emitting = true
#	._enter_state()
#
## Inverse of enter_state.
func _exit_state():
	entity.set_collision_mask_bit(0, true)
	._exit_state()

var t = 0.0
var t_2 = 0.0

func _process_state(delta):
	if t <= 0.0:
		if entity.feet.get_overlapping_bodies().size() == 0:
			t_2 -= delta
			if t_2 <= 0.0:
				set_next_state("fall")
				return
		else:
			t_2 = 0.1
		
		if entity.raycast.is_colliding():
			if not entity.ledge_detect_high.is_colliding():
				entity.set_collision_mask_bit(0, false)
				t = 0.08
				
	else:
		entity.translate(Vector3(0.0, 15 * delta, 0.0))
		t -= delta
		if t <= 0.0 and not entity.get_collision_mask_bit(0):
#			entity.set_collision_layer_bit(2, true)
			entity.set_collision_mask_bit(0, true)
		
	var stick = entity.input_listener.sticks[0]
	if abs(stick) > 0.1:
		ang_momentum = clamp(-stick * max_turn_speed, -max_turn_speed, max_turn_speed)
	
	elif entity.input_listener.is_key_pressed(InputManager.RIGHT):
		current_turn_dir = 1
		turn_acc = lerp(turn_acc, 1, delta * 10)
		ang_momentum = clamp(ang_momentum - delta * rot_speed * turn_acc, -max_turn_speed, max_turn_speed)
#
	elif entity.input_listener.is_key_pressed(InputManager.LEFT):
		current_turn_dir = -1
		turn_acc = lerp(turn_acc, 1, delta * 10)
		ang_momentum = clamp(ang_momentum + delta * rot_speed * turn_acc, -max_turn_speed, max_turn_speed) 
		
	else:
		current_turn_dir = 0
		ang_momentum = lerp(ang_momentum, 0, delta * rot_drag)
		
	if current_turn_dir != prev_turn_dir:
		turn_acc = 0.0
		prev_turn_dir = current_turn_dir
	
	if entity.input_listener.is_key_released(InputManager.RUN) and entity.input_listener.is_key_released(InputManager.UP):
		target_speed -= delta * 10
		if target_speed <= 0.0:
			set_next_state("run_stop")
			return
			
	elif target_speed > max_speed:
		target_speed -= delta * 5
		
	elif target_speed < max_speed:
		target_speed = max_speed
		max_turn_speed = 3.2
	
	if entity.is_on_wall():
		var wall_normal = entity.get_slide_collision(0).normal
#		var wall_position = entity.get_slide_collision(0).position
		var player_vector = -entity.model_container.transform.basis.z
		var rot = Vector2(player_vector.x, player_vector.z).angle_to(Vector2(wall_normal.x, wall_normal.z))
		entity.model_container.rotation.y -= PI * 0.2 * sign(rot)
		
		if wall_normal.dot(player_vector) > -0.8:
			entity.velocity *= 0.5
			entity.velocity += wall_normal * entity.prev_speed * 0.25
		else:
			entity.velocity = wall_normal * entity.prev_speed
			
	entity.model_container.rotation_degrees.y += ang_momentum
	entity.accelerate(-target_speed, delta * acceleration)
#	entity.apply_drag(delta)
	entity.apply_gravity(delta)
	
	entity.center_camera(delta)
	entity.emit_signal("rotation_changed", entity.model_container.rotation.y)
		
##func _animation_blend_started(anim_name):
##	print(anim_name)
##	set_next_state("idle")
##	if anim_name == "off_h_r_heavy":
#
func _animation_finished(anim_name):
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
		"jump",
		]

func _received_input(key, state):
	if state:
		if key == InputManager.BREAK:
			set_next_state("run_stop")
			return
		if key == InputManager.RUN_RUN or key == InputManager.UP_UP:
#			if target_speed <= 13:
			target_speed = boost_speed
			max_turn_speed = 2.3
#			entity.set_velocity(Vector3(0.0, 0.0, -target_speed))
#			acceleration = 2.0
#			entity.emit_one_shot("ParticlesBoost")
#			if target_speed < 22:
#				target_speed += 6
#			else:
#				target_speed = 22
				
#			released_up = true
#			if entity.get_current_animation() == "run_loop":
#				entity.set_animation("off_run_stop", 0, 10.0)
#			set_next_state("run_stop")
#			return
#	else:
#		if key == :
##			set_next_state("run_stop")
#			target_speed -= delta
#			print("ASD")
#			return
		
	._received_input(key, state)
