extends Spatial
class_name NetworkedObject

# warning-ignore:unused_signal
signal networked_object_event(_name, event_name, args)

var owner_id : int
var id : int

func _init():
	owner_id = NetworkManager.my_id
	id = NetworkManager.get_new_uid()

func _ready():
	add_to_networked_objects()
	add_properties_to_update()

func add_to_networked_objects():
	get_node("/root/Stage/NetworkInterface").add_to_networked_objects(id, self)

func remove_from_networked_objects():
	get_node("/root/Stage/NetworkInterface").remove_from_networked_object(id)

func add_properties_to_update():
	return
