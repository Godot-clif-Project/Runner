extends Spatial
class_name NetworkedObject

# warning-ignore:unused_signal
signal networked_object_event(_name, event_name, args)

var owner_id : int
var object_id : int

func _init():
	owner_id = NetworkManager.my_id
	object_id = NetworkManager.get_new_uid()

func _ready():
	get_node("/root/Stage/NetworkInterface").add_networked_object(object_id, self)

func remove_from_networked_objects():
	get_node("/root/Stage/NetworkInterface").remove_networked_object(object_id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
