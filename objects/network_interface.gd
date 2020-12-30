extends Node

const PEER_SCENE = preload("res://entities/sword_figher/peer_sword_fighter.tscn")
const NETWORK_UPDATE_RATE = 0.016

export var enabled = true

var player_entity
var peer_entities : Dictionary
# Each NetworkedObject that is created by any player adds it's id here. This variable is kept in synch for all peers.
var remote_networked_objects : Dictionary
var update_time : float
# Each NetworkedObject that is created by the server adds it's id and list of properties to update here.
var objects_to_update : Dictionary


func get_peer_at_index(i):
	return peer_entities[peer_entities.keys()[i]]

func _ready():
	set_physics_process(false)
	NetworkManager.network_interface = self
	
	if enabled and get_tree().has_network_peer():
		NetworkManager.connect("peer_disconnected", self, "peer_disconnected")
		NetworkManager.connect("server_disconnected", self, "server_disconnected")
		
		player_entity = get_node("../SwordFighter")
		
		if get_tree().is_network_server():
			set_physics_process(true)
#		else:
#			AudioServer.set_bus_mute(0, true)
			
#		player_entity.connect("ready", self, "player_ready")
		player_entity.connect("hp_changed", self, "player_entity_hp_changed")
		player_entity.connect("transform_changed", self, "player_entity_transform_changed")
		player_entity.connect("position_changed", self, "player_entity_position_changed")
		player_entity.connect("rotation_changed", self, "player_entity_rotation_changed")
		player_entity.connect("animation_changed", self, "player_entity_animation_changed")
		player_entity.connect("dealt_tandem_action", self, "player_entity_dealt_tandem_action")
		
		var i = 0
		
		for peer_id in NetworkManager.peers.keys():
			if peer_id == NetworkManager.my_id:
				player_entity.setup(NetworkManager.peers[NetworkManager.my_id]["player_number"])
			else:
				var new_peer_entity = PEER_SCENE.instance()
				peer_entities[peer_id] = new_peer_entity
				peer_entities[peer_id].owner_id = peer_id
				peer_entities[peer_id].network_interface = self
				$"../UI/PlayerNames".get_children()[i].text = NetworkManager.peers[peer_id]["name"]
				$"../UI/PlayerNames".get_children()[i].visible = true
				peer_entities[peer_id].my_lifebar = $"../UI/Lifebars".get_children()[i]
				peer_entities[peer_id].my_lifebar.visible = true
				i += 1
				
				call_deferred("add_peer_entity", new_peer_entity, NetworkManager.peers[peer_id]["player_number"])
				
	else: # Singleplayer
		player_entity = get_node("../SwordFighter")
		player_entity.setup(1)
		enabled = false

func add_peer_entity(new_peer_entity, player_number):
	$"..".add_child(new_peer_entity)
	new_peer_entity.setup(player_number)

func peer_disconnected(id):
	enabled = false
	
func server_disconnected():
	enabled = false
	
func _physics_process(delta):
	if update_time >= NETWORK_UPDATE_RATE:
		var update_data = Dictionary()
		
		for object_id in objects_to_update.keys():
			update_data[object_id] = Dictionary()
			for property in objects_to_update[object_id]:
				update_data[object_id][property] = remote_networked_objects[object_id].get(property)
			
			rpc_unreliable("update_networked_objects", update_data)
			
		update_time = 0.0
	else:
		update_time += delta

func create_new_networked_object(object_id : int, resource_name : String, args : Dictionary):
	if enabled:
		rpc("peer_created_networked_object", NetworkManager.my_id, object_id, resource_name, args)

func add_to_networked_objects(object_id, object):
#	if get_tree().has_network_peer():
		remote_networked_objects[object_id] = object
		remote_networked_objects[object_id].connect("networked_object_event", self, "receive_networked_object_event")
		
func remove_from_networked_object(object_id):
	if get_tree().has_network_peer():
		if remote_networked_objects.has(object_id):
			remote_networked_objects.erase(object_id)

func receive_networked_object_event(object_id : int, function_name : String, args : Array):
	if enabled:
		rpc("receive_networked_object_event_from_peer", object_id, function_name, args)

func player_entity_hp_changed(new_value):
	if enabled:
		rpc("update_peer_hp", NetworkManager.my_id, new_value)

func player_entity_transform_changed(new_value):
	if enabled:
		rpc_unreliable("update_peer_transform", NetworkManager.my_id, new_value)

func player_entity_position_changed(new_value, new_velocity):
	if enabled:
		rpc_unreliable("update_peer_position", NetworkManager.my_id, new_value, new_velocity)

func player_entity_rotation_changed(new_value):
	if enabled:
		rpc_unreliable("update_peer_rotation", NetworkManager.my_id, new_value)
	
func player_entity_animation_changed(anim_name, seek_pos, blend_speed):
	if enabled:
		rpc("update_peer_animation", NetworkManager.my_id, anim_name, seek_pos, blend_speed)

func player_entity_dealt_tandem_action(action, args):
	if enabled:
		for peer in peer_entities:
			peer_entities[peer].rpc("dealt_tandem_action", NetworkManager.my_id, action, args)

remote func peer_created_networked_object(owner_id : int, object_id : int, object_resource_name : String, args : Dictionary):
	args["owner_id"] = owner_id
	MainManager.current_level.create_object(object_resource_name, args)
	NetworkManager.uid = object_id

remote func update_networked_objects(update_data):
	for object_id in update_data.keys():
		for property in update_data[object_id].keys():
			remote_networked_objects[object_id].set(property, update_data[object_id][property])

remote func receive_networked_object_event_from_peer(object_id : int, function_name : String, args : Array):
	if remote_networked_objects.has(object_id):
		remote_networked_objects[object_id].receive_networked_call(function_name, args)
#		remote_networked_objects[object_id].callv(function_name, args)
#	else:
#		prints(object_name, "not found in networked_objects")

remote func update_peer_hp(id, new_hp):
	peer_entities[id].my_lifebar._on_sword_fighter_hp_changed(new_hp)

remote func update_peer_transform(id, new_transform):
	peer_entities[id].transform = new_transform

remote func update_peer_position(id, new_position, velocity):
	peer_entities[id].velocity = velocity
	peer_entities[id].transform.origin = new_position

remote func update_peer_rotation(id, new_rotation):
	peer_entities[id].model_container.rotation.y = new_rotation

remote func update_peer_animation(id, anim_name, seek_pos, blend_speed):
	peer_entities[id].set_animation(anim_name, seek_pos, blend_speed)

remote func peer_received_hit_from_peer(id, hit_data):
	peer_entities[id].receive_hit(hit_data)

remote func receive_hit_from_peer(id, hit_data):
	var new_hit = Hit.new(Hit.INIT_TYPE.DEFAULT)
	for key in hit_data:
		new_hit.set(key, hit_data[key])
	player_entity.receive_hit(new_hit)
	
	# send notification of hit to other peers except the one that just hit me.
	for peer in peer_entities:
		if peer != id:
			rpc_id(peer, "peer_received_hit_from_peer", NetworkManager.my_id, hit_data)
	
#	get_tree().network_peer.set_target_peer(-id)
#	rpc("peer_received_hit_from_peer", NetworkManager.my_id, hit_data)
#	get_tree().network_peer.set_target_peer(NetworkedMultiplayerPeer.TARGET_PEER_BROADCAST)

remote func receive_throw_from_peer(pos, rot, _throwing_entity):
	player_entity.receive_throw(pos, rot, _throwing_entity)
	pass

remote func receive_tandem_action_from_peer(id, action_name, _tandem_entity):
	player_entity.receive_tandem_action(action_name, peer_entities[id])
	pass

#remotesync func player_ready():
#	get_tree().paused = false

remotesync func round_end(winner):
	get_node("../UI/RoundEnd").visible = true
	get_node("../UI/RoundEnd/Name").text = winner
	get_node("../UI/RoundEnd/Timer").start()
	get_tree().paused = true
	pass

remotesync func reset():
	get_node("../UI/RoundEnd").visible = false
	player_entity.reset()
	for peer in peer_entities:
		peer_entities[peer].reset()

func _on_Timer_timeout():
	rpc("reset")
