extends "res://entities/sword_figher/states/sword_fighter_offensive_moves.gd"

#func get_animation_data():
	# Name, seek and blend length 
#	return ["off_h_r_heavy", 0.0, 5.0]

var released_up = false
var ang_momentum = 0.0
var rot_lerp = 5.0
var max_turn_speed = 5.5
var rot_speed = 30

var boost = false

var turn_acc = 0.0
var current_turn_dir = 0
var prev_turn_dir = 0

var bomb_throw_str = 30.0

#var t = 0.0
#var t_2 = 0.0

#############
# TODO: fix retarded target speed
#############

## Initialize state here: Set animation, add impulse, etc.
func _enter_state():
	entity.set_animation("run_loop_c", 0, 0.05)
#	if entity.horizontal_speed > entity.target_speed:
#		entity.velocity = entity.velocity.normalized() * entity.target_speed
	entity.model.rotation.z = 0.0
	entity.get_node("ModelContainer/Particles2").emitting = true
#	entity.velocity.z = entity.prev_velocity.z
#	entity.velocity = entity.velocity.rotated(Vector3.UP, entity.model_container.rotation.y)
#	entity.accelerate(-entity.target_speed, 0.01)
#	entity.acceleration = 1.0
#	._enter_state()
#
## Inverse of enter_state.
func _exit_state():
	entity.model.rotation = Vector3(0, PI, 0.0)
#	entity.set_collision_mask_bit(0, true)
	entity.anim_tree["parameters/TimeScale/scale"] = 1
	entity.acceleration = 0.0
	._exit_state()

func _process_state(delta):
	
	if entity.feet.get_overlapping_bodies().size() == 0:
#		if entity.target_speed > entity.MAX_SPEED:
#			set_next_state("running_fall")
#			return
#		else:
		set_next_state("fall")
		return
			
#		if t > 0.05:
#			set_next_state("running_fall")
#			return
#		t += delta
		
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
		
	ang_momentum = lerp(ang_momentum, -add_direction() * max_turn_speed * (1 - (entity.target_speed / entity.BOOST_SPEED) * 0.5), delta * rot_lerp)
#	ang_momentum = lerp(ang_momentum, -direction * max_turn_speed, delta * rot_lerp)
	
	if current_turn_dir != prev_turn_dir:
		turn_acc = 0.0
		prev_turn_dir = current_turn_dir
	
	if entity.input_listener.is_key_pressed(InputManager.BREAK):
#		entity.ground_drag = 15
#		entity.ground_drag = 8.5
#		entity.acceleration = 0.0
		if entity.horizontal_speed <= entity.MIN_SPEED:
			set_next_state("run_stop")
			return
		entity.target_speed = lerp(entity.target_speed, 0.0, delta * 0.75)
		pass
	else:
		if boost:
			entity.target_speed = entity.BOOST_SPEED
#			entity.hp -= 50 * delta
		else:
#			if entity.target_speed > entity.MAX_SPEED:
		#		entity.target_speed -= delta * 50
#				entity.target_speed = lerp(entity.target_speed, entity.MAX_SPEED, delta * 1.5)
		#		print(entity.target_speed)
#			else:
			if entity.input_listener.is_key_pressed(InputManager.RUN):
#				entity.target_speed = lerp(entity.target_speed, entity.MAX_SPEED, delta * 2)
				entity.target_speed = entity.MAX_SPEED
			else:
				if entity.horizontal_speed <= entity.MIN_SPEED:
					set_next_state("run_stop")
					return
				
				if entity.target_speed > entity.MAX_SPEED * entity.input_listener.analogs[7]:
					entity.target_speed = lerp(entity.target_speed, entity.MAX_SPEED * entity.input_listener.analogs[7], delta * 0.25)
#					entity.target_speed = entity.MAX_SPEED * entity.input_listener.analogs[7]
				else:
					entity.target_speed = lerp(entity.target_speed, entity.MAX_SPEED * entity.input_listener.analogs[7], delta * 2)
	
	# slow down when turning
#	entity.target_speed *= 1 - abs(ang_momentum) / (max_turn_speed * 6)
	
	# rotate character freely
	entity.model_container.rotation_degrees.y += ang_momentum
	
	# + turn speed dependant on velocity
#	entity.model_container.rotation_degrees.y += ang_momentum * float(1 - entity.target_speed / entity.BOOST_SPEED * 0.5)
	
	# rotate character dependant on velocity
#	var vel_angle = atan2(entity.velocity.x, entity.velocity.z)
#	entity.model_container.rotation.y = vel_angle + PI + ang_momentum * 0.25

#	entity.model.look_at(-entity.raycast_floor.get_collision_normal() + entity.translation, Vector3.UP)
#	entity.model.rotation.y = -PI
	entity.align_to_floor(delta)
	
	entity.acceleration = clamp((entity.acceleration + delta * 2), 0.0, 1.0)
	entity.accelerate(-entity.target_speed, delta * entity.acceleration * 3)
	
	entity.apply_gravity(delta)
	entity.apply_velocity(delta)
	
	entity.anim_tree["parameters/TimeScale/scale"] = float(entity.target_speed / (entity.BOOST_SPEED * 0.6)) + 0.4# + (0.75 - entity.acceleration * 0.75)
	entity.center_camera(delta * 2, Vector2.ZERO)
	entity.emit_signal("rotation_changed", entity.model_container.rotation.y)
	
#	entity.translation = Vector3.ZERO

#	if entity.input_listener.is_key_pressed(InputManager.HEAVY):
#		bomb_throw_str = clamp(bomb_throw_str + delta * 600, 3.0, 30.0)

func _touched_surface(surface):
	if surface == "wall":
		hit_wall()
	
	elif surface == "obstacle":
		entity.set_animation("run_bump_r", 0.0, 0.05)
		entity.play_sound("step")
		entity.velocity *= 0.25
#				MainManager.current_level.spawn_effect("weak_hit", entity.translation + Vector3.UP, Vector3.ZERO)
#				entity.play_sound("hit_random")

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
#		"sidestep",
		"slide",
		"air_atk",
		]

func _received_input(key, state):
	if state:
		if key == InputManager.FIRE:
			if entity.input_listener.is_key_pressed(InputManager.EVADE):
				entity.throw_stamina_bomb(Vector3(0.0, bomb_throw_str * 0.25, -bomb_throw_str))
				return
				
		if key == InputManager.BREAK_BREAK:
			set_next_state("run_stop")
			return
			
#		if key == InputManager.RUN_RUN or key == InputManager.UP_UP or key == InputManager.FIRE:
		if key == InputManager.RUN_RUN or key == InputManager.UP_UP:
			boost = true
			entity.play_sound("boost")
#			if entity.target_speed <= entity.MAX_SPEED:
##			if entity.hp > 0:
#				entity.hp -= 25
#				entity.target_speed = entity.BOOST_SPEED
#				entity.acceleration = 0.85
#				entity.play_sound("boost")
				
		if key == InputManager.JUMP:
			if entity.input_listener.is_key_pressed(InputManager.BREAK):
				set_next_state("jump")
				return
			else:
				set_next_state("running_fall")
				return
		if key == InputManager.SLIDE:
			entity.velocity = entity.velocity.normalized() * clamp(entity.horizontal_speed * 1.25, 0.0, entity.BOOST_SPEED * 1.5)
	else:
		if key == InputManager.RUN:
			boost = false
#			bomb_throw_str = 0.0
			
#		if key == InputManager.FIRE:
#			if entity.target_speed <= entity.MAX_SPEED:
#				entity.target_speed = entity.BOOST_SPEED * boost_charge
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
