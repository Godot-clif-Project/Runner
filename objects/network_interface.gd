extends Node

export var enabled = true

var player_entity
var peer_entity
var remote_networked_objects = {}

func _ready():
	set_physics_process(false)
	NetworkManager.network_interface = self
	
	if enabled and get_tree().has_network_peer():
		player_entity = get_node("../SwordFighter")
		peer_entity = get_node("../PeerSwordFighter")
		peer_entity.network_interface = self
		
		if get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED:
			NetworkManager.connect("peer_disconnected", self, "peer_disconnected")
			NetworkManager.connect("server_disconnected", self, "server_disconnected")
			
			player_entity.connect("ready", self, "player_ready")
			player_entity.connect("hp_changed", self, "player_entity_hp_changed")
			player_entity.connect("transform_changed", self, "player_entity_transform_changed")
			player_entity.connect("position_changed", self, "player_entity_position_changed")
			player_entity.connect("rotation_changed", self, "player_entity_rotation_changed")
			player_entity.connect("animation_changed", self, "player_entity_animation_changed")
			player_entity.connect("dealt_tandem_action", self, "player_entity_dealt_tandem_action")
#			player_entity.connect("dealt_hit", self, "player_entity_dealt_hit")
			player_entity.lock_on_target = peer_entity
			
			if get_tree().is_network_server():
				player_entity.setup(1)
				peer_entity.setup(2)
				set_physics_process(true)
				
			else:
				player_entity.setup(2)
				peer_entity.setup(1)
				AudioServer.set_bus_mute(0, true)
				
#				get_node("../UI/PlayerName1").text = NetworkManager.peers[NetworkManager.peers.keys()[0]]["name"]
#				get_node("../UI/PlayerName2").text = NetworkManager.my_info["name"]
				
			get_node("../UI/PlayerName1").text = NetworkManager.my_info["name"]
			get_node("../UI/PlayerName2").text = NetworkManager.peers[NetworkManager.peers.keys()[0]]["name"]
			player_entity.get_node("PlayerName/ViewportContainer/Viewport/Label").text = NetworkManager.my_info["name"]
			peer_entity.get_node("PlayerName/ViewportContainer/Viewport/Label").text = NetworkManager.peers[NetworkManager.peers.keys()[0]]["name"]
	else:
		player_entity = get_node("../SwordFighter")
		player_entity.setup(1)
		enabled = false

func peer_disconnected(id):
	enabled = false
	
func server_disconnected():
	enabled = false
	
func _physics_process(delta):
	var dummy_id = $"../Dummy".object_id
	rpc_unreliable("update_networked_objects", {dummy_id : {"translation" : remote_networked_objects[dummy_id].translation}})

func create_new_networked_object(object_id : int, resource_name : String, args : Dictionary):
	if enabled:
		rpc("peer_created_networked_object", NetworkManager.my_id, object_id, resource_name, args)
	pass

func add_networked_object(object_id, object):
#	if get_tree().has_network_peer():
		remote_networked_objects[object_id] = object
		remote_networked_objects[object_id].connect("networked_object_event", self, "receive_networked_object_event")
		
func remove_networked_object(object_id):
	if get_tree().has_network_peer():
		if remote_networked_objects.has(object_id):
			remote_networked_objects.erase(object_id)

func receive_networked_object_event(object_id : int, function_name : String, args : Array):
	if enabled:
		rpc("receive_networked_object_event_from_peer", object_id, function_name, args)

func player_entity_hp_changed(new_value):
	if enabled:
		peer_entity.rpc_unreliable("update_hp", NetworkManager.my_id, new_value)

func player_entity_transform_changed(new_value):
	if enabled:
		peer_entity.rpc_unreliable("update_transform", NetworkManager.my_id, new_value)

func player_entity_position_changed(new_value):
	if enabled:
		peer_entity.rpc_unreliable("update_position", NetworkManager.my_id, new_value)

func player_entity_rotation_changed(new_value):
	if enabled:
		peer_entity.rpc_unreliable("update_rotation", NetworkManager.my_id, new_value)
	
func player_entity_animation_changed(anim_name, seek_pos, blend_speed):
	if enabled:
		peer_entity.rpc("update_animation", NetworkManager.my_id, anim_name, seek_pos, blend_speed)

func player_entity_dealt_tandem_action(action, args):
	peer_entity.rpc("dealt_tandem_action", NetworkManager.my_id, action, args)

remote func update_networked_objects(objects_to_update):
	for object_name in objects_to_update.keys():
		for property in objects_to_update[object_name].keys():
			remote_networked_objects[object_name].set(property, objects_to_update[object_name][property])

remote func peer_created_networked_object(owner_id, object_id : int, object_resource_name : String, args : Dictionary):
	args["owner_id"] = owner_id
#	args["name"] = object_name
	MainManager.current_level.create_object(object_resource_name, args)
	NetworkManager.uid = object_id
#	prints("name", NetworkManager.my_id, args["name"])

remote func receive_networked_object_event_from_peer(object_id : int, function_name : String, args : Array):
	if remote_networked_objects.has(object_id):
		remote_networked_objects[object_id].callv(function_name, args)
#	else:
#		prints(object_name, "not found in networked_objects")
	
#func player_entity_dealt_hit(hit):
#	if enabled:
#		var hit_data = {
#			"name" : hit.name,
#			"damage" : hit.damage,
#			"knockback" : hit.knockback,
#			"direction" : hit.direction,
#			"grab" : hit.grab,
#			}
#		rpc("receive_hit_from_peer", NetworkManager.my_id, hit_data)

remote func receive_hit_from_peer(id, hit_data):
	var new_hit = Hit.new(Hit.INIT_TYPE.DEFAULT)
	for key in hit_data:
		new_hit.set(key, hit_data[key])
	peer_entity.set_hitstop(hit_data.hitstop, false)
#	player_entity._receive_hit(new_hit)

	# QUACKEADA for hit effects to appear:
	player_entity.get_node("ModelContainer/sword_fighter/Armature/Skeleton/BoneAttachment/Hurtbox").receive_hit(new_hit)

remote func receive_throw_from_peer(pos, rot, _throwing_entity):
	player_entity.receive_throw(pos, rot, peer_entity)
	pass

remote func receive_tandem_action_from_peer(action_name, entity):
	player_entity.receive_tandem_action(action_name, peer_entity)
	pass

remotesync func player_ready():
	get_tree().paused = false

remotesync func round_end(winner):
	get_node("../UI/RoundEnd").visible = true
	get_node("../UI/RoundEnd/Name").text = winner
	get_node("../UI/RoundEnd/Timer").start()
	get_tree().paused = true
	pass

remotesync func reset():
	get_node("../UI/RoundEnd").visible = false
	player_entity.reset()
	peer_entity.reset()

func _on_Timer_timeout():
	rpc("reset")
