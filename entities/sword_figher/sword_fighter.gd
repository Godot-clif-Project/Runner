extends KinematicBody
class_name Entity

signal hp_changed(new_value)
# warning-ignore:unused_signal
signal transform_changed(new_value)
signal position_changed(new_value)
signal rotation_changed(new_value)
signal animation_changed(anim_name, seek_pos, blend_speed)
signal dealt_hit(hit)
signal requested_camera(entity)

enum Stances {OFFENSIVE, DEFENSIVE, UNIQUE}
const TERMINAL_VELOCITY = -50
const PLAYER_1_MATERIAL = preload("res://entities/sword_figher/sword_fighter_player_1.material")
const PLAYER_2_MATERIAL = preload("res://entities/sword_figher/sword_fighter_player_2.material")

export(NodePath) var target
export var walk_speed = 3
export var default_ground_drag = 10
export var ground_drag = 10
export var default_tracking_speed = 20
export var tracking_speed = 20
export var max_hp = 1000
export var min_jump_str = 2.5
export var max_jump_str = 25

var ready = false
var player_side = 0
var hp = 1000 setget set_hp
var received_hit : Hit
var has_camera = false setget set_has_camera
var camera_side = 1
var target_point = Vector3.ZERO
var target_rotation = 0.0
var motion_vector = Vector3.ZERO
var velocity = Vector3.ZERO
var on_ground = true
var root_motion = Vector3.ZERO
var animation_ended = false
var old_animation = ""
var animation_slot = 1
var current_stance = Stances.UNIQUE
var throwing_entity = null
var receive_throw_pos = Vector3.ZERO
var receive_throw_rot = 0.0
var jump_str = 0

onready var lock_on_target : Spatial = get_node(target)
onready var input_listener = $InputListener
onready var model = $ModelContainer/sword_fighter
onready var camera_pivot = $CameraPointPivot
onready var camera_point = $CameraPointPivot/Position3D
onready var default_camera_pos = $CameraPointPivot/Position3D.translation
onready var model_container = $ModelContainer
onready var anim_tree = $AnimationTree
onready var anim_player = $ModelContainer/sword_fighter/AnimationPlayer
onready var animation_blender = $AnimationBlender
onready var fsm = $FSM
onready var flags = $AnimationFlags
onready var feet = $ModelContainer/Feet
onready var ledge_detect_low = $ModelContainer/LedgeDetectLow
onready var ledge_detect_high = $ModelContainer/LedgeDetectHigh
onready var ledge_detect_r = $ModelContainer/LedgeDetectR
onready var ledge_detect_l = $ModelContainer/LedgeDetectL
onready var raycast = $ModelContainer/RayCast

func set_hp(value):
	hp = clamp(value, 0, max_hp)
	emit_signal("hp_changed", hp)

func set_has_camera(value):
	has_camera = value
	if value:
		input_listener.reverse_left_right = false
#		input_listener.reverse_up_down = false
	else:
		input_listener.reverse_left_right = true
#		input_listener.reverse_up_down = true

func get_direction():
	return model_container.transform.basis.get_euler()

func _ready():
	fsm.setup()
	$AnimationTree.active = true
	ready = true
	emit_signal("ready")
	
	
func setup(side):
	player_side = side
	if player_side == 1:
		transform = get_node("../Player1Pos").transform
		connect("hp_changed", get_node("../Lifebar"), "_on_sword_fighter_hp_changed")
		$ModelContainer/sword_fighter/Armature/Skeleton/Cube.material_override = PLAYER_1_MATERIAL
		$ModelContainer/sword_fighter/Armature/Skeleton/sword.material_override = PLAYER_1_MATERIAL
	else:
		transform = get_node("../Player2Pos").transform
		connect("hp_changed", get_node("../Lifebar2"), "_on_sword_fighter_hp_changed")
		$ModelContainer/sword_fighter/Armature/Skeleton/Cube.material_override = PLAYER_2_MATERIAL
		$ModelContainer/sword_fighter/Armature/Skeleton/sword.material_override = PLAYER_2_MATERIAL

func reset():
	self.hp = max_hp
	fsm.setup()
	if throwing_entity != null:
		remove_collision_exception_with(throwing_entity)
	if player_side == 1:
		transform = get_node("../Player1Pos").transform
	else:
		transform = get_node("../Player2Pos").transform
	emit_signal("ready")

#const arrow = preload("res://misc/arrow.tscn")
#onready var arrow = get_node("../Arrow")

func get_normal():
	raycast.force_raycast_update()
#	var point = raycast.get_collision_point()
	var normal = raycast.get_collision_normal()
	var t = Transform.IDENTITY.looking_at(normal, Vector3.UP)
	
#	arrow.transform = t
#	arrow.transform.origin = point
	
	return t.basis.get_euler()

func _on_InputListener_received_input(key, state):
	fsm.receive_event("_received_input", [key, state])
#	if key == InputManager.LIGHT:
#		a.transform = Transform(raycast.get_collision_normal(), raycast.get_collision_point())
#		a.translation = raycast.get_collision_point()
#	if state:

func _input(event):
	if event is InputEventMouseMotion:
		camera_pivot.rotation.y += deg2rad(input_listener.mouse_motion.x * -0.1)
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x + deg2rad(input_listener.mouse_motion.y * -0.1), -1.5, 0.9)
#	elif event is InputEventJoypadMotion:
#			if event.axis == 2:
#				camera_pivot.rotation.y += event.axis_value * -0.1
#				sticks[event.axis] = event.axis_value
	if event.is_action_pressed("debug_reset"):
		reset()

var count = 0

func _physics_process(delta):
	
	camera_pivot.rotation.y += input_listener.sticks[2] * -0.1
	camera_pivot.rotation.x = clamp(camera_pivot.rotation.x + input_listener.sticks[3] * -0.1, -1.5, 0.9)
	target_rotation = camera_pivot.rotation.y
	
#	target_point = lock_on_target.global_transform.origin
##	target_point = Vector3(target_point.x, 1.5, target_point.z)
#
#	var target_vector = global_transform.origin.direction_to(target_point)
#	target_rotation = PI + atan2(target_vector.x, target_vector.z)
#
#	camera_point.look_at(target_point + Vector3(0.0, 1.0, 0.0), Vector3.UP)
	
#	$CameraPointPivot/Position3D.rotation.z = 0
#	$CameraPointPivot/Position3D.rotation.y = 0
#	$CameraPointPivot/Position3D.rotation.x = 0
	
#	if count > 3:
#		print(atan2(target_vector.z, target_vector.x))
#		count = 0
#	count += 1

#	var current_rot = camera_pivot.rotation.y
#	camera_pivot.rotation.y = lerp_angle(current_rot, target_rotation, delta * 15)
	
#	var start = $ModelContainer/CameraPointPivot.transform.basis.get_euler()
#	var end = Quat(target_vector)
	
#	$ModelContainer/CameraPointPivot.transform.basis = Basis(start.slerp(end, delta))
	
#	var dir_vector = global_transform.origin.direction_to(target_point)
#	var target_transform = $ModelContainer/CameraPointPivot.global_transform.looking_at(dir_vector)
#	var my_dir = transform.basis.get_rotation_quat()
	
#			if (target.length() > 0.001):
#	var q_from = Quat($ModelContainer/CameraPointPivot.transform.basis.orthonormalized())
#	var q_to = Quat($ModelContainer/CameraPointPivot.transform.looking_at(target_point, Vector3(0,1,0)).basis)
#	
			# interpolate current rotation with desired one
	
	
	
#	model.translation = model.get_node("Armature/Skeleton").get_bone_pose(0).origin / 1.65
#	print(model.get_node("Armature/Skeleton").get_bone_pose(0).origin)

#	var y_velocity = velocity.y
#
#	if motion_vector != Vector3.ZERO:
#		pass
#	else:
	
#	root_motion = -model.get_node("Armature/Skeleton").get_bone_pose(0).origin
#	model.get_node("Armature/Skeleton").set_bone_pose(0, Transform.IDENTITY)
	
	
#	if not on_ground:
#		if feet.get_overlapping_bodies().size() > 0:
#			fsm.receive_event("_touched_surface", "floor")
	
	
#	velocity = move_and_slide_with_snap(velocity, Vector3.DOWN, Vector3.UP, false, 4, 0.785398, true)
#	move_and_slide(velocity, Vector3.UP, false, 4, 0.785398, true)
#	if count > 4:
#		prints(name, velocity)
#		prints(is_on_floor())
#		count = 0
#	count += 1
	
	fsm._process_current_state(delta, true)
	
	velocity = move_and_slide(velocity, Vector3.UP, false, 4, 0.785398, true)
	
	if input_listener.is_key_pressed(InputManager.GUARD):
		if jump_str < max_jump_str:
			jump_str += max_jump_str * delta * 4
			
#	emit_signal("transform_changed", transform)
	emit_signal("position_changed", transform.origin)
	
#	print(Vector2(velocity.x, velocity.z).length())

func center_camera(delta):
	camera_pivot.rotation.y = lerp_angle(camera_pivot.rotation.y, model_container.rotation.y, delta * 2)

func apply_gravity(delta):
	if velocity.y > TERMINAL_VELOCITY:
		if not is_on_floor():
			velocity.y -= 9.8 * delta * 8
		else:
			velocity.y -= 9.8 * delta * 0.3
	else:
		velocity.y = TERMINAL_VELOCITY

func apply_rotation(delta):
	velocity = velocity.rotated(Vector3.UP, model_container.rotation.y)

var target_velocity = Vector3.ZERO
var current_velocity = Vector3.ZERO

var target_vector = Vector2.ZERO

func set_velocity(_velocity):
	var velocity_rotated = _velocity.rotated(Vector3.UP, model_container.rotation.y)
	velocity = Vector3(velocity_rotated.x, velocity.y, velocity_rotated.z)
	
func accelerate(speed : float, delta):
	target_velocity = Vector3(0.0, 0.0, speed).rotated(Vector3.UP, model_container.rotation.y)
#	velocity = velocity.normalized() * abs(speed)
#	velocity = velocity.normalized() * target_velocity.length()
	velocity = velocity.linear_interpolate(target_velocity, delta * 4.5)
	
	model.rotation_degrees.z = clamp(Vector2(velocity.x, velocity.z).angle_to(Vector2(target_velocity.x, target_velocity.z)) * 45, -30, 30)
	
func lerp_velocity(delta):
#	var interpolated_vector = Vector2(velocity.x, velocity.z).linear_interpolate(target_velocity, delta * 4.5)
#	velocity = Vector3(interpolated_vector.x, velocity.y, interpolated_vector.y)
#	var interpolated_vector = Vector2(velocity.x, velocity.z).linear_interpolate(target_velocity, delta * 4.5)
#	var model_rot = model.rotation_degrees
	
#	var interpolated_vector = velocity.linear_interpolate(target_velocity, delta * 4.5)
	
	velocity = velocity.linear_interpolate(target_velocity, delta * 4.5)
#	current_velocity = velocity

	model.rotation_degrees.z = clamp(Vector2(velocity.x, velocity.z).angle_to(Vector2(target_velocity.x, target_velocity.z)) * 45, -30, 30)
	
#	prints("v", velocity)
#	prints("t", target_velocity)

	

func set_target_velocity(_target_velocity):
#	current_velocity = velocity.normalized()
	velocity = velocity.normalized() * _target_velocity.length()
#	var rotated_vector = _target_velocity.rotated(Vector3.UP, model_container.rotation.y)
	target_velocity = _target_velocity.rotated(Vector3.UP, model_container.rotation.y)
	target_velocity.y = velocity.y
	
#	var rotated_vector = _velocity.rotated(Vector3.UP, model_container.rotation.y)
#	velocity = Vector3(rotated_vector.x, velocity.y, rotated_vector.z)
	
func add_impulse(value : Vector3):
	velocity += value.rotated(Vector3.UP, model_container.rotation.y)

func apply_tracking(delta):
	var current_rot = model_container.rotation.y
	model_container.rotation.y = lerp_angle(current_rot, target_rotation, delta * tracking_speed)
#	model_container.rotation.y = target_rotation
	emit_signal("rotation_changed", model_container.rotation.y)
	
func apply_drag(delta):
	if velocity.length_squared() < 0.05:
		velocity.x = 0.0
		velocity.z = 0.0
	else:
#		if abs(velocity.x) > 0: 
#		velocity.x -= ground_drag * delta * sign(velocity.x)
#		if abs(velocity.z) > 0: 
#		velocity.z -= ground_drag * delta * sign(velocity.z)
		var negative_vector = velocity.rotated(Vector3.UP, deg2rad(180)).normalized() * ground_drag * delta
		velocity += Vector3(negative_vector.x, 0.0, negative_vector.z)
#	print(velocity)

func apply_root_motion(delta):
	
#	if flags.no_root_motion_to_speed and root_motion.length() < 0.1:
#		old = root_motion
#		print("ASD")
#	else:
#		speed = root_motion - old
#		old = root_motion
	
#	if (root_motion - old).length() < 0.1 or flags.no_root_motion_to_speed:
#		speed = root_motion - old
#	old = root_motion
#	velocity = (speed).rotated(Vector3.UP, model_container.rotation.y) * 40
	var root_motion_speed = -anim_tree.get_root_motion_transform().origin.rotated(Vector3.UP, model_container.rotation.y) * 40
	velocity = Vector3(root_motion_speed.x, velocity.y, root_motion_speed.z)
#	print(-anim_tree.get_root_motion_transform().origin)
	pass

func jump():
	velocity.y = 0.0
	var direction = Vector2.ZERO
	if input_listener.is_key_pressed(InputManager.UP):
		direction += Vector2.UP
	if input_listener.is_key_pressed(InputManager.DOWN):
		direction += Vector2.DOWN
	if input_listener.is_key_pressed(InputManager.LEFT):
		direction += Vector2.LEFT
	if input_listener.is_key_pressed(InputManager.RIGHT):
		direction += Vector2.RIGHT
	direction = direction.normalized() * 5
	
	add_impulse(Vector3(direction.x, jump_str , direction.y))
	on_ground = false
	jump_str = min_jump_str

func get_current_animation():
	return $AnimationEvents.assigned_animation

func set_animation(anim_name, seek_pos, blend_speed):
	
	if $AnimationEvents.has_animation(anim_name):
		$AnimationEvents.stop()
		$AnimationEvents.play(anim_name)
#		$AnimationEvents.current_animation = anim_name
	
	if animation_slot == -1:
		anim_tree.tree_root.get_node("animation_1").animation = anim_name
		anim_tree["parameters/animation_1_seek/seek_position"] = seek_pos
	else:
		anim_tree.tree_root.get_node("animation_-1").animation = anim_name
		anim_tree["parameters/animation_-1_seek/seek_position"] = seek_pos

	# Blend animations:

	if animation_blender.is_playing():
		animation_blender.stop(false)
#		print(animation_blender.current_animation_position)

	if animation_slot == 1:
		if blend_speed == -1.0:
			anim_tree["parameters/1_and_-1/blend_amount"] = 1.0
			pass
		else:
			animation_blender.play("blend_animation_1_animation_-1", -1, blend_speed)
#			prints("start blending from slot 0", anim_tree.tree_root.get_node("animation_0").animation,
#			"to", anim_tree.tree_root.get_node("animation_1").animation)
	else:
		if blend_speed == -1.0:
			anim_tree["parameters/1_and_-1/blend_amount"] = 0.0
		else:
			animation_blender.play("blend_animation_1_animation_-1", -1, -blend_speed, true)
#			prints("start blending from slot 1", anim_tree.tree_root.get_node("animation_1").animation,
#			"to", anim_tree.tree_root.get_node("animation_0").animation)

	animation_slot = -animation_slot
	emit_signal("animation_changed", anim_name, seek_pos, blend_speed)

func is_blending():
	return animation_blender.is_playing()

func start_blend_with_space(backwards):
	fsm.receive_event("_animation_blend_started", "asd")
	if not backwards:
		animation_blender.play("blend_animation_and_space", -1, 5.0)
	else:
		animation_blender.play("blend_animation_and_space", -1, -5.0, true)

func _on_AnimationBlender_animation_finished(anim_name):
	pass # Replace with function body.

func blend_ended(side):
	if side == 1:
		prints("ended blend from slot 0", anim_tree.tree_root.get_node("animation_0").animation,
		"to", anim_tree.tree_root.get_node("animation_1").animation)
	else:
		prints("ended blend from slot 1", anim_tree.tree_root.get_node("animation_1").animation,
		"to", anim_tree.tree_root.get_node("animation_0").animation)

func _on_AnimationFlags_flag_changed(flag, value):
	if ready:
		fsm.receive_event("_flag_changed", [flag, value])

func _on_AnimationEvents_animation_finished(anim_name):
	fsm.receive_event("_animation_finished", anim_name)

func request_camera(side):
	if not has_camera:
		set_camera_side(side)
		emit_signal("requested_camera", self)

func set_camera_side(side):
#	if not has_camera:
#		return
		
	camera_side = side
	camera_point.translation.x = default_camera_pos.x * side
	camera_point.look_at(target_point + Vector3(0.0, 1.0, 0.0), Vector3.UP)

func tween_camera_position(position):
	if not has_camera:
		return

	$Tween.interpolate_property(
		$CameraPointPivot/Position3D, "translation",
		camera_point.translation, Vector3(position, camera_point.translation.y, camera_point.translation.z), 1,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	if position != 0:
		camera_side = sign(position)
#	$Tween.interpolate_property(
#		$CameraPointPivot/Position3D, "rotation_degrees",
#		camera_rot, Vector3(camera_rot.x, 15 * sign(position), camera_rot.z), 1,
#		Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		
	$Tween.start()

func reset_hitboxes():
	$ModelContainer/Hitbox.active = false
	$ModelContainer/Hitbox2.active = false

func _receive_hit(hit):
	received_hit = hit
	fsm.receive_event("_received_hit", hit)

func _on_Hurtbox_received_hit(hit, hurtbox):
	_receive_hit(hit)

func _on_Hitbox_dealt_hit(hit : Hit, collided_entity):
	fsm.receive_event("_dealt_hit", collided_entity)
	emit_signal("dealt_hit", hit)
	
func receive_throw(pos, rot, _throwing_entity):
	throwing_entity = _throwing_entity
	receive_throw_pos = pos
	receive_throw_rot = rot
	
#	add_collision_exception_with(_throwing_entity)
#	translation = pos
#	model_container.rotation.y = rot
	pass

#func follow_throw_position(delta):
#	if throwing_entity != null:
#		translation = throwing_entity.get_node("ModelContainer/sword_fighter/Armature/Skeleton/ThrowAttachment").global_transform.origin

func _on_RSide_body_entered(body):
	if not body == self and body is KinematicBody:
		if body.get_current_animation() == "run_loop":
			if has_camera:
				body.request_camera(-1)
			else:
				request_camera(-1)

func _on_LSide_body_entered(body):
	if not body == self and body is KinematicBody:
		if body.get_current_animation() == "run_loop":
			if has_camera:
				body.request_camera(1)
			else:
				request_camera(1)

func _on_Feet_body_entered(body):
	if not on_ground:
		fsm.receive_event("_touched_surface", "floor")

func emit_one_shot():
	$ModelContainer/Particles.emitting = true
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	$ModelContainer/Particles.emitting = false

func _on_LedgeDetect_body_entered(body):
	pass # Replace with function body.
