extends "res://entities/sword_figher/states/sword_fighter_state.gd"

const DIRECTION_ANIMS = {
	Vector2.UP : "off_walk_forward",
	Vector2.DOWN : "off_walk_back",
	Vector2.LEFT : "off_walk_left",
	Vector2.RIGHT : "off_walk_right",
	Vector2(-1, 1) : "off_walk_back",
	Vector2(1, 1) : "off_walk_back",
	Vector2(1, -1) : "off_walk_forward",
	Vector2(-1, -1) : "off_walk_forward",
	Vector2.ZERO : "",
}

var direction = Vector2.ZERO
var old_direction = Vector2.ZERO
var transitions = .get_possible_transitions()

func get_possible_transitions():
	return transitions

# Initialize state here: Set animation, add impulse, etc.
func _enter_state():
	transitions.erase("walk")
	
	add_direction()
	old_direction = direction
	entity.set_animation("off_walk_forward", 0, 0.2)
#	entity.set_animation(DIRECTION_ANIMS[direction], -1, 0.25)
	pass

# Inverse of enter_state.
#func _exit_state():
#	pass

func _process_state(delta):
	if entity.feet.get_overlapping_bodies().size() == 0:
		set_next_state("fall")
		return
	
	direction = Vector2.ZERO
	add_direction()
	
	if direction == Vector2.ZERO:
		set_next_state("offensive_stance")
		return
	else:
		entity.model_container.rotation.y = lerp_angle(
			entity.model_container.rotation.y,
			entity.camera_pivot.rotation.y + atan2(direction.x, direction.y) + PI,
			delta * 8
			)
		
#	elif old_direction != direction:
#		entity.set_animation(DIRECTION_ANIMS[direction], 0, 0.2)
#		old_direction = direction
	
#	entity.anim_tree["parameters/walk_blend/blend_position"] = direction #* blend_amount
#	entity.motion_vector = Vector3(direction.x, 0, direction.y).normalized()
#	entity.motion_vector = Vector3(direction.x, 0, direction.y)

	
	entity.apply_gravity(delta)
#	entity.apply_tracking(delta)
	entity.apply_root_motion(delta)
	entity.emit_signal("rotation_changed", entity.model_container.rotation.y)

func add_direction():
	direction = Vector2(entity.input_listener.analogs[0], entity.input_listener.analogs[1])
	
	if entity.input_listener.is_key_pressed(InputManager.UP):
		direction += Vector2.UP
	if entity.input_listener.is_key_pressed(InputManager.DOWN):
		direction += Vector2.DOWN
	if entity.input_listener.is_key_pressed(InputManager.LEFT):
		direction += Vector2.LEFT
	if entity.input_listener.is_key_pressed(InputManager.RIGHT):
		direction += Vector2.RIGHT
	
	direction.x = clamp(direction.x, -1.0, 1.0)
	direction.y = clamp(direction.y, -1.0, 1.0)

func _received_input(key, state):
	if state:
		if key == InputManager.QUICK_TURN:
			entity.model_container.rotation.y = entity.camera_pivot.rotation.y + atan2(direction.x, direction.y) + PI
			set_next_state("run")
			return
		if key == InputManager.FIRE:
			if entity.input_listener.is_key_pressed(InputManager.EVADE):
				entity.throw_stamina_bomb(Vector3(0.0, 5, -5))
				return
	._received_input(key, state)
		
#	if key == InputManager.LIGHT:
#		set_next_state("off_hi_light")
#	elif key == InputManager.HEAVY:
#		set_next_state("off_hi_heavy")
#	elif key == InputManager.RUN:
#		if entity.input_listener.is_key_pressed(InputManager.RUN):
#			set_next_state("off_kick")
#		else:
#			set_next_state("off_block")
