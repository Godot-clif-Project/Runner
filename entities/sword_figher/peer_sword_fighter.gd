extends KinematicBody
class_name PeerEntity

# warning-ignore:unused_signal
signal hp_changed(new_value)

const ANIMATION_NODE_RESOURCE = preload("res://entities/sword_figher/sword_fighter_animation_node.tres")

var network_interface
var owner_id : int
var number = 2
var animation_slot = 1
var throwing_entity = null
var throw_pos = Vector3.ZERO
var throw_rot = 0.0

var shake_t = 0.0
#var hitstop = false
#var timescale = 1.0

onready var model = $ModelContainer/sword_fighter
onready var model_container = $ModelContainer
onready var anim_tree = $AnimationTree
onready var anim_player = $ModelContainer/sword_fighter/AnimationPlayer
onready var animation_blender = $AnimationBlender
onready var rope_point = $ModelContainer/RopePoint
onready var rope_model = $ModelContainer/Rope
onready var dust = $ModelContainer/Particles2
onready var my_lifebar

func _ready():
#	$AnimationTree.active = true
#	var new_resource = 
	$AnimationTree.tree_root = ANIMATION_NODE_RESOURCE.duplicate(true)
	set_physics_process(false)

func setup(_number):
	number = _number
	
#	if number == 1:
#		my_lifebar = get_node("../UI/Lifebar2")
#		get_node("../UI/PlayerName2").text = NetworkManager.peers[owner_id]["name"]
#	else:
#		get_node(str("../UI/PlayerName", number)).text = NetworkManager.peers[owner_id]["name"]
#		my_lifebar = get_node(str("../UI/Lifebar", number))
		
	$PlayerName/ViewportContainer/Viewport/Label.text = NetworkManager.peers[owner_id]["name"]
	$ModelContainer/sword_fighter/Armature/Skeleton/Cube.material_override = $"..".PLAYER_MATERIALS[number]
	$ModelContainer/sword_fighter/Armature/Skeleton/sword.material_override = $"..".PLAYER_MATERIALS[number]

func reset():
	if throwing_entity != null:
		remove_collision_exception_with(throwing_entity)

func _on_Hurtbox_received_hit(hit, hurtbox):
	var hit_data = {
		"name" : hit.name,
		"damage" : hit.damage,
		"knockback" : hit.knockback,
		"position" : hit.position,
		"direction" : hit.direction,
		"guard_break" : hit.guard_break,
		"grab" : hit.grab,
		"hitstop" : hit.hitstop,
		}
	network_interface.rpc_id(owner_id, "receive_hit_from_peer", NetworkManager.my_id, hit_data)
	receive_hit(hit_data)
	pass

func receive_hit(hit_data):
	set_hitstop(hit_data.hitstop, true)
	MainManager.current_level.spawn_effect(Hit.VISUAL_EFFECTS.BLUNT, hit_data.position, Vector3())
	play_sound("hit_random")

func set_hitstop(length, shake):
	anim_tree["parameters/TimeScale/scale"] = 0.05
	$AnimationEvents.playback_speed = 0.05
	$ModelContainer/SlashParticles.speed_scale = 0.05
	$HitstopTimer.start(length)
	if shake:
		shake_t = 50
		set_physics_process(true)
	else:
		shake_t = 0

func _physics_process(delta):
	if shake_t > 0.0:
		$ModelContainer/sword_fighter.translation = (Vector3.RIGHT * (shake_t * 0.03)) * sin(shake_t) * 0.1
		shake_t -= delta * 50
	else:
		set_physics_process(false)

func receive_throw(pos, rot, _throwing_entity):
	throwing_entity = _throwing_entity
	throw_pos = pos
	throw_rot = rot
	
	network_interface.rpc("receive_throw_from_peer", pos, rot, _throwing_entity)
	pass

func throw_stared():
	add_collision_exception_with(throwing_entity)
	translation = throw_pos
	model_container.rotation.y = throw_rot

func throw_ended():
	remove_collision_exception_with(throwing_entity)

func receive_tandem_action(action_name, entity):
	network_interface.rpc("receive_tandem_action_from_peer", action_name, entity)

remote func update_transform(id, new_transform):
	if id == owner_id:
		transform = new_transform

remote func update_position(id, new_position):
	if id == owner_id:
		transform.origin = new_position

remote func update_rotation(id, new_rotation):
	if id == owner_id:
		model_container.rotation.y = new_rotation

remote func update_animation(id, anim_name, seek_pos, blend_speed):
	if id == owner_id:
		$ModelContainer/sword_fighter/slash.visible = false
		$ModelContainer/SlashParticles.emitting = false
		
		if $AnimationEvents.has_animation(anim_name):
			$AnimationEvents.play(anim_name)
		
		if animation_slot == -1:
			anim_tree.tree_root.get_node("animation_1").animation = anim_name
			anim_tree["parameters/animation_1_seek/seek_position"] = seek_pos
		else:
			anim_tree.tree_root.get_node("animation_-1").animation = anim_name
			anim_tree["parameters/animation_-1_seek/seek_position"] = seek_pos

		# Blend animations:

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
	
remote func update_hp(id, new_hp):
	if id == owner_id:
		my_lifebar._on_sword_fighter_hp_changed(new_hp)

remote func dealt_tandem_action(id, action, args):
#	if action == "rope_pull":
#		rope_model.visible = true
#		rope_model.scale.z = translation.distance_to(args[0])
#		rope_model.look_at(args[0], Vector3.UP)
#		get_node("ModelContainer/Rope/AnimationPlayer").play("default")
	pass

func _on_HitstopTimer_timeout():
	anim_tree["parameters/TimeScale/scale"] = 1.0
	$AnimationEvents.playback_speed = 1.0
	$ModelContainer/SlashParticles.speed_scale = 1.0
#	set_physics_process(false)

func play_sound(sound_name):
	$Sound.play(sound_name)
