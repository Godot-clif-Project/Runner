extends Node

const PEER_SCENE = preload("res://entities/sword_figher/peer_sword_fighter.tscn")

export var enabled = true

var player_entity
var peer_entities : Dictionary
var remote_networked_objects = {}

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
				peer_entities[peer_id].my_lifebar = $"../UI/Lifebars".get_children()[i]
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
		for peer in peer_entities:
			peer_entities[peer].rpc_unreliable("update_hp", NetworkManager.my_id, new_value)

func player_entity_transform_changed(new_value):
	if enabled:
		for peer in peer_entities:
			peer_entities[peer].rpc_unreliable("update_transform", NetworkManager.my_id, new_value)

func player_entity_position_changed(new_value):
	if enabled:
		for peer in peer_entities:
			peer_entities[peer].rpc_unreliable("update_position", NetworkManager.my_id, new_value)

func player_entity_rotation_changed(new_value):
	if enabled:
		for peer in peer_entities:
			peer_entities[peer].rpc_unreliable("update_rotation", NetworkManager.my_id, new_value)
	
func player_entity_animation_changed(anim_name, seek_pos, blend_speed):
	if enabled:
		for peer in peer_entities:
			peer_entities[peer].rpc("update_animation", NetworkManager.my_id, anim_name, seek_pos, blend_speed)

func player_entity_dealt_tandem_action(action, args):
	if enabled:
		for peer in peer_entities:
			peer_entities[peer].rpc("dealt_tandem_action", NetworkManager.my_id, action, args)

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

remote func peer_received_hit_from_peer(id, hit_data):
	peer_entities[id].receive_hit(hit_data)

remote func receive_hit_from_peer(id, hit_data):
	var new_hit = Hit.new(Hit.INIT_TYPE.DEFAULT)
	for key in hit_data:
		new_hit.set(key, hit_data[key])
	player_entity.set_hitstop(hit_data.hitstop, false)

	# QUACKEADA for hit effects to appear:
	player_entity.get_node("ModelContainer/sword_fighter/Armature/Skeleton/BoneAttachment/Hurtbox").receive_hit(new_hit)
	
	# send notification of hit to other peers except the one that just hit me.
	for peer in peer_entities:
		if peer != id:
			rpc_id(peer, "peer_received_hit_from_peer", NetworkManager.my_id, hit_data)
	

remote func receive_throw_from_peer(pos, rot, _throwing_entity):
	player_entity.receive_throw(pos, rot, _throwing_entity)
	pass

remote func receive_tandem_action_from_peer(action_name, _tandem_entity):
	player_entity.receive_tandem_action(action_name, _tandem_entity)
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
