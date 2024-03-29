extends KinematicBody
class_name Entity

signal hp_changed(new_value)
# warning-ignore:unused_signal
signal transform_changed(new_value)
signal position_changed(new_value, new_velocity)
signal rotation_changed(new_value)
signal animation_changed(anim_name, seek_pos, blend_speed)
signal dealt_hit(hit)
# warning-ignore:unused_signal
signal dealt_tandem_action(action, args)
signal requested_camera(entity)

enum Stances {OFFENSIVE, DEFENSIVE, UNIQUE}
enum Modes {PLAYER, PEER}

const TERMINAL_VELOCITY = -50
const PLAYER_1_MATERIAL = preload("res://entities/sword_figher/sword_fighter_player_1.material")
const PLAYER_2_MATERIAL = preload("res://entities/sword_figher/sword_fighter_player_2.material")

export(int, "Player", "Peer") var mode = Modes.PLAYER
export(NodePath) var target
export var walk_speed = 3
export var default_ground_drag = 10
export var ground_drag = 10
export var default_tracking_speed = 20
export var tracking_speed = 20
export var max_hp = 1000
export var min_jump_str = 15
export var max_jump_str = 15
export var weight = 70
export var gravity_scale = 1.0

var ready = false
var player_number = 0
var hp = 1000 setget set_hp
var received_hit : Hit
var has_camera = false setget set_has_camera
var camera_side = 1
var target_point = Vector3.ZERO
var target_rotation = 0.0
#var motion_vector = Vector3.ZERO
var velocity = Vector3.ZERO
var on_ground = true #setget set_on_ground
var root_motion = Vector3.ZERO
var animation_ended = false
var old_animation = ""
var animation_slot = 1
var current_stance = Stances.UNIQUE
var throwing_entity = null
var receive_throw_pos = Vector3.ZERO
var receive_throw_rot = 0.0

var jump_str = 15
var horizontal_speed = 0.0
var falling_speed = 0.0
var acceleration = 0.0
var target_speed = 13.0
const MIN_SPEED = 3.0
const MAX_SPEED = 15.0
const BOOST_SPEED = 18.0

var prev_speed = 0.0
var prev_velocity : Vector3
const MAX_AIR_BOOSTS = 1
var air_boosts_left = 1
var has_wall_run = true
var has_wall_run_side = true
var wall_has_ledge = false
var wall_side = 0
var wall_rot : Vector3
var wall_pos : Vector3

var lock_on_target = null
var tandem_entity = null

var clinging_to_entity = null

var rigidbodies = []

var timescale = 1.0
var hitstop = false
var shake_t = 0.0

var bomb_charge = 100.0

onready var camera_pivot = $CameraPointPivot
onready var camera_point = $CameraPointPivot/Position3D
onready var camera_raycast = $CameraPointPivot/RayCast
onready var default_camera_pos = $CameraPointPivot/Position3D.translation
var camera = null

onready var input_listener = $InputListener
onready var model = $ModelContainer/sword_fighter
onready var model_container = $ModelContainer
onready var anim_tree = $AnimationTree
onready var anim_player = $ModelContainer/sword_fighter/AnimationPlayer
onready var animation_blender = $AnimationBlender
onready var fsm = $FSM
onready var flags = $AnimationFlags

onready var feet = $ModelContainer/Feet
onready var ledge_detect_low = $ModelContainer/LedgeDetectLow
onready var ledge_detect_high = $ModelContainer/LedgeDetectHigh
onready var raycast_cling = $ModelContainer/RayCastCling
onready var raycast_floor = $ModelContainer/RayCastFloor
onready var clingbox = $ModelContainer/Clingbox

onready var rope_point = $ModelContainer/RopePoint

onready var raycast_side = {
	-1 : $ModelContainer/RayCastL,
	1 : $ModelContainer/RayCastR,
}
onready var raycast_side_high = {
	-1 : $ModelContainer/RayCastLHigh,
	1 : $ModelContainer/RayCastRHigh,
}

onready var vel_arrow = $VelocityArrow
onready var bomb_ui = $"../UI/BombCooldown"
onready var speed_ui = $"../UI/Speed"

func set_on_ground(value):
	on_ground = value
	if value:
		gravity_scale = 4.0
	else:
		gravity_scale = 1.0
		

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
	if mode == Modes.PLAYER:
		fsm.setup()
		if not target.is_empty():
			lock_on_target = get_node(target)
		if camera != null:
			camera_raycast.enabled = true
	else:
		input_listener.enabled = false
		
	$AnimationTree.active = true
	ready = true
	emit_signal("ready")
	
func setup(number):
	player_number = number
	get_node("../UI/MyName").text = NetworkManager.my_info["name"]
	connect("hp_changed", get_node("../UI/MyLifebar"), "_on_sword_fighter_hp_changed")
	transform = get_node(str("../Player", number, "Pos")).transform
	$PlayerName/ViewportContainer/Viewport/Label.text = NetworkManager.my_info["name"]
	$ModelContainer/sword_fighter/Armature/Skeleton/Cube.material_override = $"..".PLAYER_MATERIALS[number]
	$ModelContainer/sword_fighter/Armature/Skeleton/sword.material_override = $"..".PLAYER_MATERIALS[number]
#
#	if number != 1:
#		input_listener.listen_to_pads = []

func reset():
	self.hp = max_hp
	velocity = Vector3.ZERO
	has_wall_run = true
	has_wall_run_side = true
	air_boosts_left = 1
	gravity_scale = 1.0
	model_container.rotation.y = 0.0
	fsm.setup()
	if throwing_entity != null:
		remove_collision_exception_with(throwing_entity)
	translation = get_node("../Player" + str(player_number) + "Pos").translation
	emit_signal("ready")

#const arrow = preload("res://misc/arrow.tscn")
#onready var arrow = get_node("../Arrow")

func get_normal_side(side):
	raycast_side[side].force_raycast_update()
	var normal = raycast_side[side].get_collision_normal()
	var t = Transform.IDENTITY.looking_at(normal, Vector3.UP)
#	wall_pos = raycast_side[side].get_collision_point() + normal * 0.1
	wall_pos = raycast_side[side].get_collision_point()
	
	if raycast_side[side].is_colliding():
		wall_has_ledge = raycast_side[side].get_collider().is_in_group("ledge")
	else:
		wall_has_ledge = false
	
	return t.basis.get_euler()

func get_normal():
	ledge_detect_low.force_raycast_update()
	wall_pos = ledge_detect_low.get_collision_point()
	var normal = ledge_detect_low.get_collision_normal()
	var t = Transform.IDENTITY.looking_at(normal, Vector3.UP)
	
	if ledge_detect_low.is_colliding():
		wall_has_ledge = ledge_detect_low.get_collider().is_in_group("ledge")
	else:
		wall_has_ledge = false
		
#	arrow.transform = t
#	arrow.transform.origin = point
	
	return t.basis.get_euler()

func has_los_to_target(_target):
	if translation.distance_to(_target.rope_point.global_transform.origin) > 50:
		return false
	else:
#		var space_state = get_world().direct_space_state
		var result = get_world().direct_space_state.intersect_ray(rope_point.global_transform.origin, _target.rope_point.global_transform.origin, [self], 0b00000000000000000011)
		if not result.empty() and result["collider"] is KinematicBody:
			return true
		else:
			return false

func play_rope_animation():
	lock_on_target.receive_tandem_action("rope_pull", self)
	emit_signal("dealt_tandem_action", "rope_pull", [lock_on_target.rope_point.global_transform.origin])
	
#	rope_model.scale = Vector3.ONE * clamp(translation.distance_to(lock_on_target.rope_point.global_transform.origin), 1, 10)
#	rope_model.look_at(lock_on_target.rope_point.global_transform.origin, Vector3.UP)
#	rope_model.visible = true
#	get_node("ModelContainer/Rope/AnimationPlayer").stop()
#	get_node("ModelContainer/Rope/AnimationPlayer").play("default")

var lock_on_scroll = 0

func _on_InputListener_received_input(key, state):
	if mode == Modes.PLAYER:
		fsm.receive_event("_received_input", [key, state])
	#	prints(key, state)
		
		if key == InputManager.EVADE:
			if state:
				if get_tree().has_network_peer():
					lock_on_target = $"../NetworkInterface".get_peer_at_index(lock_on_scroll)
					camera.ally_indicator.get_node("Label").text = NetworkManager.peers[lock_on_target.owner_id]["name"]
					lock_on_scroll += 1
					if lock_on_scroll > $"../NetworkInterface".peer_entities.size() - 1:
						lock_on_scroll = 0
						
					camera.ally_indicator.visible = true
					camera.set_process(true)
					
				if target.is_empty():
					return
				else:
					camera.ally_indicator.visible = true
					camera.set_process(true)
			else:
				camera.ally_indicator.visible = false
				camera.set_process(false)

func _input(event):
	if event is InputEventMouseMotion:
		camera_pivot.rotation.y += deg2rad(input_listener.mouse_motion.x * -0.1)
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x + deg2rad(input_listener.mouse_motion.y * -0.1), -1.5, 0.9)
#	elif event is InputEventJoypadMotion:
		
#			if event.axis == 2:
#				camera_pivot.rotation.y += event.axis_value * -0.1
#				analogs[event.axis] = event.axis_value
	if event.is_action_pressed("debug_reset"):
		reset()

#func _process(delta):

func _physics_process(delta):
	if mode == Modes.PLAYER:
		fsm._process_current_state(delta * timescale, true)
		
		if camera != null:
			camera_pivot.rotation.y += input_listener.analogs[2] * -0.1
			camera_pivot.rotation.x = clamp(camera_pivot.rotation.x + input_listener.analogs[3] * -0.1, -1.5, 0.9)
			target_rotation = camera_pivot.rotation.y

			if camera_raycast.is_colliding():
				var distance = camera_pivot.to_local(camera_raycast.get_collision_point()).z
				if distance < default_camera_pos.z:
					if distance < camera_point.translation.z - 0.5:
						camera_point.translation.z = distance - 0.1
						camera.translation = camera_point.global_transform.origin
					else:
						camera_point.translation.z = distance - 0.1

			elif $CameraPointPivot/Position3D/CameraCollision.get_overlapping_bodies().empty():
				if camera_point.translation.z < 3.5:
					camera_point.translation.z += delta * 3

			camera_raycast.cast_to = camera_point.translation + Vector3(0.0, 0.0, 0.2)
		
		if shake_t > 0.0:
			$ModelContainer/sword_fighter.translation = (Vector3.RIGHT * (shake_t * 0.03)) * sin(shake_t) * 0.1
			shake_t -= delta * 50
		
		if bomb_charge < 100.0:
			bomb_charge += delta
			bomb_ui.value = bomb_charge
			if bomb_charge >= 100.0:
				bomb_charge = 100.0
				bomb_ui.value = 100
				bomb_ui.modulate = Color(0.470588, 0.87451, 0.223529)
		
		speed_ui.set_text(str(stepify(horizontal_speed, 0.1)))
#	if hp < max_hp:
#		self.hp += delta * 10
	

func apply_velocity(delta):
#	if not rigidbodies.empty():
#		for body in rigidbodies:
#			var body_normal = (translation - body.translation)
#			velocity += Vector3(body_normal.x, 0.0, body_normal.z) * timescale
	
	prev_speed = horizontal_speed
	prev_velocity = velocity
	
	if on_ground:
		velocity = move_and_slide_with_snap(velocity * timescale, Vector3.DOWN, Vector3.UP, true, 1, deg2rad(50), true) / timescale
#		velocity = move_and_slide(velocity * timescale, Vector3.UP, true, 1, deg2rad(50), true) / timescale
	else:
		velocity = move_and_slide(velocity * timescale, Vector3.UP, true, 1, deg2rad(50), true) / timescale

#	velocity = move_and_slide(velocity * timescale, Vector3.UP, true, 1, deg2rad(50), true) / timescale
		
	horizontal_speed = Vector2(velocity.x, velocity.z).length()
	emit_signal("position_changed", transform.origin, velocity)
#	emit_signal("transform_changed", transform)

	if get_slide_count() != 0 and get_slide_collision(0).collider is StaticBody:
		if is_on_wall():
			fsm.receive_event("_touched_surface", "wall")
		if not on_ground and is_on_floor():
			fsm.receive_event("_touched_surface", "floor")
	
	vel_arrow.look_at(velocity + translation + Vector3.FORWARD * 0.01, Vector3.UP)
	vel_arrow.scale.z = lerp(0, 1.0, horizontal_speed / 6)
	
#	print(horizontal_speed)
func align_to_floor(delta):
	if raycast_floor.is_colliding():
		var floor_normal = raycast_floor.get_collision_normal()
		var target_vector = floor_normal.cross(-model_container.transform.basis.x)
		model.look_at((translation + lerp(-model.global_transform.basis.z, target_vector, delta * 3)), Vector3.UP)
	else:
		model.rotation = Vector3(0, PI, model.rotation.z)

func center_camera(delta, offset : Vector2):
	var at = atan2(velocity.y, velocity.z)
	if abs(at) < 0.01 or abs(at) > 3.1:
		at = -0.2
	else:
		at = clamp(atan2(velocity.y, velocity.z) - 0.2, -PI * 0.1, PI * 0.1)
	camera_pivot.rotation.x = lerp_angle(camera_pivot.rotation.x, at + offset.x, delta * 0.5)
	camera_pivot.rotation.y = lerp_angle(camera_pivot.rotation.y, model_container.rotation.y + offset.y, delta)

func point_camera_at_target(delta, offset):
	var current_camera_direction = Quat(camera_pivot.global_transform.basis)
	var target_dir = Quat(camera_pivot.global_transform.looking_at(lock_on_target.translation + offset, Vector3.UP).basis)
	var q = current_camera_direction.slerp(target_dir, delta)
	camera_pivot.transform.basis = Basis(q)
	camera_pivot.rotation.z = 0.0

func apply_gravity(delta):
	if velocity.y > TERMINAL_VELOCITY:
		if not is_on_floor():
			velocity.y -= 9.8 * delta * gravity_scale * 5.5
		else:
			velocity.y -= 9.8 * delta * gravity_scale * 0.5
	else:
		velocity.y = TERMINAL_VELOCITY

func apply_rotation(delta):
	velocity = velocity.rotated(Vector3.UP, model_container.rotation.y)

var target_velocity = Vector3.ZERO
var current_velocity = Vector3.ZERO

func set_velocity(_velocity : Vector3):
	var velocity_rotated = _velocity.rotated(Vector3.UP, model_container.rotation.y)
#	velocity = Vector3(velocity_rotated.x, velocity.y, velocity_rotated.z)
	velocity = velocity_rotated

func turn(ang_momentum):
	velocity = velocity.rotated(Vector3.UP, ang_momentum * 0.005)
	model_container.rotation.y = atan2(velocity.x, velocity.z) + PI + ang_momentum* 0.33

func accelerate(speed : float, delta):
#	velocity = velocity.normalized() * abs(speed)
#	velocity = velocity.normalized() * target_velocity.length()
	target_velocity = Vector3(0.0, 0.0, speed).rotated(Vector3.UP, model_container.rotation.y)
	velocity = velocity.linear_interpolate(target_velocity, delta)

#	var velocity_xz = Vector2(velocity.x, velocity.z).linear_interpolate(Vector2(target_velocity.x, target_velocity.z), delta * 3)
#	velocity.x = velocity_xz.x
#	velocity.z = velocity_xz.y
	
	model.rotation_degrees.z = clamp(Vector2(velocity.x, velocity.z).angle_to(Vector2(target_velocity.x, target_velocity.z)) * 90, -30, 30)
	
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
	apply_velocity(delta)
#	print(-anim_tree.get_root_motion_transform().origin)
	pass

func jump():
	velocity.y = 0.0
	velocity *= 0.75
	self.on_ground = false
	
	var direction = Vector2.ZERO
	if input_listener.is_key_pressed(InputManager.RUN) or input_listener.is_key_pressed(InputManager.UP):
		direction += Vector2.UP
#	if input_listener.is_key_pressed(InputManager.DOWN):
#		direction += Vector2.DOWN
#	if input_listener.is_key_pressed(InputManager.LEFT):
#		direction += Vector2.LEFT
#	if input_listener.is_key_pressed(InputManager.RIGHT):
#		direction += Vector2.RIGHT
	direction = direction.normalized() * 2
	
#	add_impulse(Vector3(0.0, jump_str , 0.0))
#	set_velocity(Vector3(direction.x, 0.0 , direction.y))
#	add_impulse(Vector3(direction.x, jump_str , direction.y))
	add_impulse(Vector3(0.0, jump_str , direction.y))
#	add_impulse(Vector3(0.0, jump_str , -5))
	
#	if Vector2(velocity.x, velocity.z).length() > 20:
#		var v = Vector2(velocity.x, velocity.z).normalized() * 20
#		velocity.x = v.x
#		velocity.z = v.y
		
	play_sound("jump")
#	jump_str = min_jump_str

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

#	if animation_blender.is_playing():
#		animation_blender.stop(false)
#		print(animation_blender.current_animation_position)

	animation_blender.stop_all()

	if animation_slot == 1:
		if blend_speed == -1.0:
			anim_tree["parameters/1_and_-1/blend_amount"] = 1.0
			pass
		else:
			animation_blender.interpolate_property(anim_tree, "parameters/1_and_-1/blend_amount", 0.0, 1.0, blend_speed, Tween.TRANS_LINEAR)
#			prints("start blending from slot 0", anim_tree.tree_root.get_node("animation_0").animation,
#			"to", anim_tree.tree_root.get_node("animation_1").animation)
	else:
		if blend_speed == -1.0:
			anim_tree["parameters/1_and_-1/blend_amount"] = 0.0
		else:
			animation_blender.interpolate_property(anim_tree, "parameters/1_and_-1/blend_amount", 1.0, 0.0, blend_speed, Tween.TRANS_LINEAR)
#			prints("start blending from slot 1", anim_tree.tree_root.get_node("animation_1").animation,
#			"to", anim_tree.tree_root.get_node("animation_0").animation)
	
	animation_blender.start()
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

#func request_camera(side):
#	if not has_camera:
#		set_camera_side(side)
#		emit_signal("requested_camera", self)

#func set_camera_side(side):
##	if not has_camera:
##		return
#
#	camera_side = side
#	camera_point.translation.x = default_camera_pos.x * side
#	camera_point.look_at(target_point + Vector3(0.0, 1.0, 0.0), Vector3.UP)
#
#func tween_camera_position(position):
#	if not has_camera:
#		return
#
#	$Tween.interpolate_property(
#		$CameraPointPivot/Position3D, "translation",
#		camera_point.translation, Vector3(position, camera_point.translation.y, camera_point.translation.z), 1,
#		Tween.TRANS_LINEAR, Tween.EASE_OUT)
#	if position != 0:
#		camera_side = sign(position)
##	$Tween.interpolate_property(
##		$CameraPointPivot/Position3D, "rotation_degrees",
##		camera_rot, Vector3(camera_rot.x, 15 * sign(position), camera_rot.z), 1,
##		Tween.TRANS_SINE, Tween.EASE_IN_OUT)
#
#	$Tween.start()

func reset_hitboxes():
	$ModelContainer/Hitbox.active = false
	$ModelContainer/Hitbox2.active = false

func receive_hit(hit):
	received_hit = hit
	MainManager.current_level.spawn_effect(Hit.VISUAL_EFFECTS.BLUNT, hit.position, Vector3.ZERO)
	set_hitstop(hit.hitstop, true)
	play_sound("hit_random")
	fsm.receive_event("_received_hit", hit)

func _on_Hurtbox_received_hit(hit, hurtbox):
	if mode == Modes.PLAYER:
		receive_hit(hit)
		set_hitstop(hit.hitstop, true)

func _on_Hitbox_dealt_hit(hit : Hit, collided_entity):
	emit_signal("dealt_hit", hit)
	set_hitstop(hit.hitstop, false)
	fsm.receive_event("_dealt_hit", collided_entity)
	
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

func receive_tandem_action(action_name, entity):
	tandem_entity = entity
	fsm.receive_event("_received_tandem_action", [action_name, entity])
	pass

#func _on_RSide_body_entered(body):
#	if not body == self and body is KinematicBody:
#		if body.get_current_animation() == "run_loop":
#			if has_camera:
#				body.request_camera(-1)
#			else:
#				request_camera(-1)
#
#func _on_LSide_body_entered(body):
#	if not body == self and body is KinematicBody:
#		if body.get_current_animation() == "run_loop":
#			if has_camera:
#				body.request_camera(1)
#			else:
#				request_camera(1)

func _on_Feet_body_entered(body):
#	if not on_ground:
#		fsm.receive_event("_touched_surface", "floor")
	pass

func emit_one_shot(_name : String):
	var node = get_node("ModelContainer/" + _name)
	
	node.emitting = true
#	$ModelContainer/Particles.restart()
	
	yield(get_tree(), "physics_frame")
#	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	node.emitting = false

func _on_RigidbodyCollision_body_entered(body):
	
	body.apply_central_impulse(velocity * (0.5 + ((weight - body.weight) / weight)))
	
#	var body_normal = (body.translation.direction_to(translation))
	var body_normal = (translation - body.translation).normalized()
	var player_vector = model_container.transform.basis.z
	var rot = Vector2(player_vector.x, player_vector.z).angle_to(Vector2(body_normal.x, body_normal.z))
	var dot = body_normal.dot(velocity.normalized())
	var weight_diff = clamp(1 - ((weight - body.weight) / weight),0 , 2)
	
	model_container.rotation.y -= PI * sign(rot) * dot * weight_diff * 0.5
	velocity += Vector3(body_normal.x, 0.0, body_normal.z) * horizontal_speed * abs(dot) * weight_diff
	
	rigidbodies.append(body)

func _on_RigidbodyCollision_body_exited(body):
	rigidbodies.erase(body)
	pass # Replace with function body.

func set_hitstop(length, shake):
	$HitstopTimer.start(length)
	hitstop = true
	timescale = 0.05
	anim_tree["parameters/TimeScale/scale"] = timescale
	$AnimationEvents.playback_speed = timescale
	$ModelContainer/SlashParticles.speed_scale = timescale
	if shake:
		shake_t = 50
	else:
		shake_t = 0.0

func _on_HitstopTimer_timeout():
	hitstop = false
	timescale = 1.0
	anim_tree["parameters/TimeScale/scale"] = timescale
	$AnimationEvents.playback_speed = timescale
	$ModelContainer/SlashParticles.speed_scale = timescale
	$ModelContainer/sword_fighter.translation = Vector3.ZERO
	pass # Replace with function body.

func get_healing_grass(heal_amount, grass):
	if hp < max_hp or bomb_charge < 100.0:
#		heal(heal_amount)
#		grass.grabbed()
#	elif bomb_charge < 100.0:
		heal(heal_amount)
		grass.grabbed()
		bomb_charge += heal_amount * 0.01
		bomb_ui.value = bomb_charge
		if bomb_charge >= 100.0:
			bomb_charge = 100.0
			bomb_ui.value = 100
			bomb_ui.modulate = Color(0.470588, 0.87451, 0.223529)
	
#			$BombTween.stop_all()
#		else:
#			$BombTween.stop_all()
#			$BombTween.interpolate_property($"../UI/BombCooldown", "value", bomb_charge, 100, 120.0 * (bomb_charge / 100.0), Tween.TRANS_LINEAR)
#			$BombTween.interpolate_property(self, "bomb_charge", bomb_charge, 100, 120.0 * (bomb_charge / 100.0), Tween.TRANS_LINEAR)
#			$BombTween.start()

func heal(heal_amount):
	$ModelContainer/sword_fighter/Armature/Skeleton/BoneAttachment/ParticlesHeal.restart()
	$ModelContainer/sword_fighter/Armature/Skeleton/BoneAttachment/ParticlesHeal.emitting = true
	play_sound("heal")
	self.hp += heal_amount

func play_sound(sound_name : String):
	$Sound.play(sound_name)

#const STAMINA_BOMB = preload("res://objects/stamina_bomb/stamina_bomb.tscn")

func throw_stamina_bomb(_velocity : Vector3):
	if bomb_charge == 100.0:
		bomb_ui.modulate = Color.white
		bomb_charge = 0
		bomb_ui.value = 0
		
#		$BombTween.stop_all()
#		$BombTween.interpolate_property($"../UI/BombCooldown", "value", 0, 100, 120.0, Tween.TRANS_LINEAR)
#		$BombTween.interpolate_property(self, "bomb_charge", 0, 100, 120.0, Tween.TRANS_LINEAR)
#		$BombTween.start()
		MainManager.current_level.create_object("stamina_bomb", {
			"velocity" : _velocity.rotated(Vector3.UP, model_container.rotation.y),
			"translation" : $ModelContainer/BombPoint.global_transform.origin
		})

func _on_BombTween_tween_all_completed():
	$"../UI/BombCooldown".modulate = Color(0.470588, 0.87451, 0.223529)


func _on_ObstacleCollision_body_entered(body):
	fsm.receive_event("_touched_surface", "obstacle")


func _on_ObstacleCollision_area_entered(area):
	fsm.receive_event("_touched_surface", "obstacle")
