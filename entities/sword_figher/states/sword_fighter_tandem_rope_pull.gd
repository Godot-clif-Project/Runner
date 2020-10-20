extends "res://entities/sword_figher/states/sword_fighter_fall.gd"

func get_animation_data():
	# Name, seek and blend length 
	return ["air_rope", 0.0, 0.1]

var initial_rot
## Initialize state here: Set animation, add impulse, etc.
func _enter_state():
#	if entity.has_los_to_target(entity.lock_on_target):
	initial_rot = entity.model_container.rotation.y
	entity.velocity.x *= 0.9
	entity.velocity.z *= 0.9
	entity.velocity.y *= 0.0
	entity.hp -= 250
#	entity.model_container.rotation.y = atan2(vector_to_target.x, vector_to_target.z) + PI
	
#	entity.lock_on_target.receive_tandem_action("rope_pull", entity)
#	entity.play_rope_animation(entity.lock_on_target.rope_point.global_transform.origin)
#	entity.emit_signal("dealt_tandem_action", "rope_pull", [entity.lock_on_target.rope_point.global_transform.origin])
	entity.get_node("../Rope").set_process(true)
	entity.get_node("../Rope").visible = true
	entity.get_node("../Rope/AnimationPlayer").play("Pull")

	._enter_state()
#
## Inverse of enter_state.
func _exit_state():
	entity.model_container.rotation = Vector3(0.0, initial_rot, 0.0)
	entity.camera_pivot.rotation.z = 0.0
	entity.model_container.transform = entity.model_container.transform.orthonormalized()
	entity.camera_pivot.transform = entity.camera_pivot.transform.orthonormalized()
	entity.gravity_scale = 1.0
	entity.get_node("../Rope").visible = false
	entity.get_node("../Rope").set_process(false)
	._exit_state()

func _process_state(delta):
	entity.model_container.transform.basis = entity.model_container.global_transform.looking_at(entity.lock_on_target.translation, Vector3.UP).basis
	entity.apply_gravity(delta)
	entity.apply_drag(delta)
	entity.apply_velocity(delta)
	if entity.flags.is_active:
#		entity.center_camera(delta * 2)
		entity.point_camera_at_target(delta * 5, Vector3(0.0, -5.0, 0.0))
	
#	entity.get_node("../Rope/Start").translation = entity.get_node("ModelContainer/sword_fighter/Armature/Skeleton/RHandAttachment").global_transform.origin
	entity.get_node("../Rope").translation = entity.get_node("ModelContainer/sword_fighter/Armature/Skeleton/RHandAttachment").global_transform.origin
	entity.get_node("../Rope").rotation.y = entity.model_container.rotation.y
	entity.get_node("../Rope/End").translation = entity.get_node("../Rope").to_local(entity.lock_on_target.translation + Vector3.UP)
	
#	entity.get_node("../Path/Path/PathFollow").unit_offset = 1.0
#	entity.apply_root_motion(delta)
##	pass
#
##func _animation_blend_started(anim_name):
##	print(anim_name)
##	set_next_state("idle")
##	if anim_name == "off_h_r_heavy":
#
func _animation_finished(anim_name):
	set_next_state("fall")
#	._animation_finished(anim_name)
#	set_next_state("offensive_stance")
#	pass
#
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
		"tandem_launch_up",
		]

#func _received_input(key, state):
#	pass
#	if entity.flags.is_stringable:
#		if state:
#			if key == InputManager.LIGHT:
#				set_next_state("off_hi_fierce")
#			if key == InputManager.HEAVY:
#				set_next_state("off_kick")
