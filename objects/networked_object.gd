extends Node
class_name NetworkedObject

# warning-ignore:unused_signal
signal networked_object_event(_name, event_name, args)

var owner_id : int
var id : int
var parent : Node

func _init():
#	owner_id = NetworkManager.my_id
	id = NetworkManager.get_new_uid()

func _ready():
	parent = get_parent()
	add_to_networked_objects()

func create(resource_name, properties):
	if parent.owner_id == null:
		NetworkManager.network_interface.create_new_networked_object(id, resource_name, properties)

func add_to_networked_objects():
	get_node("/root/Stage/NetworkInterface").add_to_networked_objects(id, self)

func remove_from_networked_objects():
	get_node("/root/Stage/NetworkInterface").remove_from_networked_object(id)

func add_properties_to_update(properties):
	get_node("/root/Stage/NetworkInterface").objects_to_update[id] = properties
	return

func receive_networked_call(function_name : String, args : Array):
	parent.callv(function_name, args)

func event(event_name : String, args : Array):
	get_node("/root/Stage/NetworkInterface").receive_networked_object_event(id, event_name, args)
#	emit_signal("networked_object_event", id, event_name, args)
