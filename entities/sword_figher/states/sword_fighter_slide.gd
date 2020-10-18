extends "res://entities/sword_figher/states/sword_fighter_offensive_moves.gd"

#func get_animation_data():
	# Name, seek and blend length 
#	return ["off_h_r_heavy", 0.0, 5.0]

var released_up = false
var ang_momentum = 0.0
var rot_lerp = 10
var rot_drag = 1
var rot_speed = 60
var max_turn_speed = 14.0
var initial_rot = 0.0

var speed = 0.0

func get_animation_data():
	# Name, seek and blend length 
	return ["run_stop", 0.0, 0.05]

## Initialize state here: Set animation, add impulse, etc.
func _enter_state():
#	entity.acceleration = 0.0
#	speed = entity.horizontal_speed
	entity.get_node("ModelContainer/Particles2").emitting = true
	initial_rot = entity.model_container.rotation_degrees.y
	entity.velocity = entity.velocity.normalized() * clamp(entity.horizontal_speed * 1.33, 0.0, entity.boost_speed * 1.25)
	entity.play_sound("stop")
#	entity.hp -= 40
	._enter_state()
	
#	if entity.input_listener.is_key_pressed(InputManager.DOWN):
#		entity.ground_drag = 20
#	else:
#		entity.ground_drag = entity.default_ground_drag
	
#	._enter_state()
#
## Inverse of enter_state.
func _exit_state():
#	entity.model.rotation.z = 0.0
	._exit_state()

var t = 1.25
var prev_momentum = 0.0
func _process_state(delta):
	entity.hp -= 40 * delta
	if entity.feet.get_overlapping_bodies().size() == 0:
		set_next_state("running_fall")
		return
	
	if entity.horizontal_speed < 10.0:
		set_next_state("run_stop")
		return
		
#	if entity.feet.get_overlapping_bodies().size() == 0:
#		set_next_state("fall")
#		return
	
	var stick = clamp(entity.input_listener.analogs[0] * 1, -1.0, 1.0)
	if abs(stick) > 0.1:
		ang_momentum = lerp(ang_momentum, -stick * max_turn_speed, delta * rot_lerp)
		
	elif entity.input_listener.is_key_pressed(InputManager.RIGHT):
		ang_momentum = clamp(ang_momentum - delta * rot_speed, -max_turn_speed, max_turn_speed)
#
	elif entity.input_listener.is_key_pressed(InputManager.LEFT):
		ang_momentum = clamp(ang_momentum + delta * rot_speed, -max_turn_speed, max_turn_speed) 
		
	else:
		ang_momentum = lerp(ang_momentum, 0, delta * rot_lerp)
	
	t = clamp(t - delta * 0.5, 0.5, 2.0)
	
#	t += delta * sign(ang_momentum) * 0.05 * stick

#	if abs(ang_momentum) < prev_momentum - 0.25:
#		set_next_state("run")
#	prev_momentum = abs(ang_momentum)

	if entity.input_listener.is_key_pressed(InputManager.BREAK):
		entity.ground_drag = 8
	else:
		entity.ground_drag = 8
	
			
#	entity.model_container.rotation_degrees.y = clamp(entity.model_container.rotation_degrees.y + ang_momentum, initial_rot - 90, initial_rot + 90)
	
#	speed = clamp(speed - delta * entity.ground_drag, 0, 25)
	entity.velocity = entity.velocity.rotated(Vector3.UP, (ang_momentum * 0.005) * t)
	var vel_angle = atan2(entity.velocity.x, entity.velocity.z)
	entity.model_container.rotation.y = vel_angle + PI + ang_momentum * 0.1
	
#	entity.turn(ang_momentum)
	entity.apply_drag(delta)
	entity.apply_gravity(delta)
	entity.apply_velocity(delta)
#	entity.camera_pivot.rotation.y = lerp_angle(entity.camera_pivot.rotation.y, entity.model_container.rotation.y - 0.5 * sign(ang_momentum), delta * 2)
	entity.center_camera(delta * 2)
	entity.emit_signal("rotation_changed", entity.model_container.rotation.y)
	
#	._process_state(delta)

func _touched_surface(surface):
	if surface == "wall":
		var wall_normal = entity.get_slide_collision(0).normal
		var wall_position = entity.get_slide_collision(0).position
		var player_vector = -entity.model_container.transform.basis.z
		var rot = Vector2(player_vector.x, player_vector.z).angle_to(Vector2(wall_normal.x, wall_normal.z))
		
#		if wall_normal.dot(player_vector) < -0.8:
		entity.velocity *= 1 - abs(wall_normal.dot(player_vector) * 0.8)
		entity.model_container.rotation.y -= (PI * 0.333) * (entity.prev_speed * 0.1) * abs(wall_normal.dot(player_vector)) * sign(rot)
		entity.velocity += wall_normal * entity.prev_speed * 0.3
		
		var _hit = Hit.new(Hit.INIT_TYPE.WALL)
		_hit.position = wall_position
		entity.receive_hit(_hit)
		
		if entity.prev_speed > 5:
			if rot > 0.0:
				entity.set_animation("run_bump_l", 0.0, 0.05)
			else:
				entity.set_animation("run_bump_r", 0.0, 0.05)

func _animation_finished(anim_name):
#	if anim_name == "run_stop":
#		entity.set_animation("run_stop_loop", 0.0, 16.0)
#	if anim_name == "run_stop_dash":
#		set_next_state("run")
#		entity.target_speed = entity.boost_speed
#		entity.acceleration = 0.75
	if anim_name == "run_bump_l" or anim_name == "run_bump_r":
		set_next_state("run")
	pass
		
#	if anim_name == "off_run_startup":
#		if released_up:
#			entity.set_animation("off_run_stop", 0, 10.0)
#		else:
#			entity.set_animation("run_loop", 0, -1.0)
#			if entity.input_listener.is_key_pressed(InputManager.RIGHT):
#				direction = 1
#				entity.tween_camera_position(0.0)
#			elif entity.input_listener.is_key_pressed(InputManager.LEFT):
#				direction = -1
#				entity.tween_camera_position(0.0)
				
#	elif anim_name == "off_run_stop":
#	set_next_state("offensive_stance")
	pass
	

func _flag_changed(flag, state):
	pass

func get_possible_transitions():
	return [
		"jump",
		"off_run_startup",
		]

func _received_input(key, state):
	if state:
		if key == InputManager.RUN or key == InputManager.UP:
#			entity.set_animation("run_stop_dash", 0.0, 20.0)
			set_next_state("run")
			entity.target_speed = entity.boost_speed
			entity.acceleration = 1.0
			return
#		elif key == InputManager.BOOST:
#			entity.set_animation("run_stop_dash", 0.0, 20.0)
#			entity.target_speed = entity.boost_speed
##			entity.acceleration = 0.8
#			return
		if key == InputManager.BREAK:
#			entity.ground_drag = 20
			set_next_state("run_stop")
			return
	else:
		if key == InputManager.FIRE:
			set_next_state("run")
#			entity.ground_drag = entity.default_ground_drag
		
	
	._received_input(key, state)
#	pass
