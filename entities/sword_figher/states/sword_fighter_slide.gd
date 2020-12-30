extends "res://entities/sword_figher/states/sword_fighter_offensive_moves.gd"

#func get_animation_data():
	# Name, seek and blend length 
#	return ["off_h_r_heavy", 0.0, 5.0]

const DOWNHILL_ACC = 1.25

var released_up = false
var ang_momentum = 0.0
var rot_lerp = 10
var max_turn_speed = 13.0
#var rot_drag = 1
var rot_speed = 60
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
	entity.velocity = entity.velocity.normalized() * clamp(entity.horizontal_speed * 1.25, 0.0, entity.boost_speed * 1.5)
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
	entity.model.rotation = Vector3(0, PI, 0.0)
#	entity.ground_drag = entity.default_ground_drag
	._exit_state()

var t = 1.25
#var prev_momentum = 0.0
func _process_state(delta):
#	entity.hp -= 25 * delta
#	if entity.feet.get_overlapping_bodies().size() == 0:
##		set_next_state("running_fall")
#		set_next_state("fall")
#		return
	
	if entity.horizontal_speed < 10.0:
		set_next_state("run_stop")
		return
	
	ang_momentum = lerp(ang_momentum, -add_direction() * max_turn_speed, delta * rot_lerp)
	
	t = clamp(t - delta * 0.5, 0.5, 2.0)
	
#	t += delta * sign(ang_momentum) * 0.05 * stick

#	if abs(ang_momentum) < prev_momentum - 0.25:
#		set_next_state("run")
#	prev_momentum = abs(ang_momentum)

#	if entity.input_listener.is_key_pressed(InputManager.BREAK):
#		entity.ground_drag = 8
#	else:
#		entity.ground_drag = 8
	
			
#	entity.model_container.rotation_degrees.y = clamp(entity.model_container.rotation_degrees.y + ang_momentum, initial_rot - 90, initial_rot + 90)
#	speed = clamp(speed - delta * entity.ground_drag, 0, 25)

	entity.ground_drag = clamp(8 + entity.velocity.y, 0, 20)
	
	rot_lerp = clamp(rot_lerp - delta * 15, 2.0, 10.0)
#	max_turn_speed = clamp(max_turn_speed - delta * 8, 10.0, 15.0)
	
	entity.velocity = entity.velocity.rotated(Vector3.UP, (ang_momentum * 0.005) * t)
	
	if not entity.feet.get_overlapping_bodies().size() == 0:
		if entity.velocity.y < 0:
			entity.velocity.x += delta * abs(entity.velocity.y) * sign(entity.velocity.x) * DOWNHILL_ACC
			entity.velocity.z += delta * abs(entity.velocity.y) * sign(entity.velocity.z) * DOWNHILL_ACC
	
	if entity.horizontal_speed > 40:
		var y = entity.velocity.y
		entity.velocity = entity.velocity.normalized() * 40
		entity.velocity.y = y
	
	var vel_angle = atan2(entity.velocity.x, entity.velocity.z)
	entity.model_container.rotation.y = vel_angle + PI + ang_momentum * 0.1
	
	entity.align_to_floor(delta)
	entity.apply_drag(delta)
	entity.apply_gravity(delta)
	entity.apply_velocity(delta)
	entity.center_camera(delta * 3, Vector2(0, ang_momentum * 0.1))
	entity.emit_signal("rotation_changed", entity.model_container.rotation.y)
	
#	._process_state(delta)

func _touched_surface(surface):
	if surface == "wall":
		set_next_state("run")
		hit_wall()

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
	if state:
		if flag == "is_evade_cancelable":
			if entity.input_listener.is_key_released(InputManager.FIRE):
				set_next_state("run")
	pass

func get_possible_transitions():
	return [
		"air_atk",
		"running_fall",
#		"jump",
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
			if entity.flags.is_evade_cancelable:
				set_next_state("run")
		
	
	._received_input(key, state)
#	pass
