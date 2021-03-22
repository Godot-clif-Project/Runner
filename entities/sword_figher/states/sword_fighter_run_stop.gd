extends "res://entities/sword_figher/states/sword_fighter_offensive_moves.gd"

#func get_animation_data():
	# Name, seek and blend length 
#	return ["off_h_r_heavy", 0.0, 5.0]

var released_up = false
var ang_momentum = 0.0
var rot_drag = 1
var rot_speed = 5
var rot_lerp = 5.0
var max_turn_speed = 6.0

## Initialize state here: Set animation, add impulse, etc.
func _enter_state():
#	entity.acceleration = 0.0
	entity.get_node("ModelContainer/Particles2").emitting = true
	entity.set_animation("run_break", 0, 0.05)
	entity.ground_drag = 8
	#	if entity.input_listener.is_key_pressed(InputManager.DOWN):
#		entity.ground_drag = 20
#	else:
#		entity.ground_drag = entity.default_ground_drag
	
#	._enter_state()
#
## Inverse of enter_state.
func _exit_state():
	entity.model.rotation.z = 0.0
	entity.model.rotation = Vector3(0, PI, 0.0)
#	entity.get_node("Sound/Stop").stop()
	._exit_state()
	
var t = 0
func _process_state(delta):
	entity.acceleration = clamp(entity.acceleration - delta, 0.0, 1.0)
	entity.jump_str = clamp(entity.horizontal_speed + 4 - t, 18, 28)
#	t += delta
	
	if entity.horizontal_speed < 4.0:
		set_next_state("offensive_stance")
		return
		
	if entity.feet.get_overlapping_bodies().size() == 0:
		set_next_state("fall")
		return
	
	ang_momentum = lerp(ang_momentum, -add_direction() * max_turn_speed, delta * rot_lerp)
	
	entity.model_container.rotation_degrees.y += ang_momentum * float(1 - entity.target_speed / entity.BOOST_SPEED * 0.5)
	entity.emit_signal("rotation_changed", entity.model_container.rotation.y)
	
#	if entity.input_listener.is_key_pressed(InputManager.FIRE):
#		entity.ground_drag = 15
#	else:
#		entity.ground_drag = 8.5
		
	entity.apply_drag(delta)
	entity.target_speed = entity.horizontal_speed
	
	entity.apply_gravity(delta)
	entity.apply_velocity(delta)
	entity.align_to_floor(delta)
	entity.center_camera(delta * 2, Vector2.ZERO)
	
#	._process_state(delta)

func _touched_surface(surface):
	if surface == "wall":
		var wall_normal = entity.get_slide_collision(0).normal
#		var wall_position = entity.get_slide_collision(0).position
		var player_vector = -entity.model_container.transform.basis.z
#		var rot = Vector2(player_vector.x, player_vector.z).angle_to(Vector2(wall_normal.x, wall_normal.z))
		
#		if wall_normal.dot(player_vector) < -0.8:
		entity.velocity *= 1 - abs(wall_normal.dot(player_vector) * 0.8)
#		entity.model_container.rotation.y -= (PI * 0.333) * (entity.prev_speed * 0.1) * abs(wall_normal.dot(player_vector)) * sign(rot)
		entity.velocity += wall_normal * entity.prev_speed * 0.3
		
		MainManager.current_level.spawn_effect("weak_hit", entity.translation + Vector3.UP, Vector3.ZERO)
		entity.play_sound("hit_random")

func _animation_finished(anim_name):
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
		"air_atk",
		]

func _received_input(key, state):
	if state:
		if key == InputManager.QUICK_TURN:
			if entity.horizontal_speed < 10:
				entity.model_container.rotation.y += PI
				set_next_state("run")
				return
		
		if key == InputManager.RUN or key == InputManager.UP:
			set_next_state("run")
			return
		elif key == InputManager.BOOST:
			set_next_state("run")
			entity.target_speed = entity.BOOST_SPEED
#			entity.acceleration = 0.8
			return
#		if key == InputManager.DOWN:
#			entity.ground_drag = 20
	else:
		if key == InputManager.BREAK:
			set_next_state("run")
#			entity.ground_drag = entity.default_ground_drag
		
	
	._received_input(key, state)
#	pass
