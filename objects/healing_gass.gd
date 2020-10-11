extends WorldObject

export var heal_amount = 200

func _ready():
	get_node("/root/Stage/NetworkInterface").add_world_object(name, self)
#	pass # Replace with function body.

#func _process(delta):
#	pass

func grabbed():
	visible = false
	$Timer.start()

func _on_Timer_timeout():
	visible = true
	pass # Replace with function body.

func _on_Area_body_entered(body):
	if visible:
		if body is Entity:
			if body.hp < body.max_hp:
				body.get_healing_grass(heal_amount, self)
				grabbed()
				emit_signal("world_object_event", name, "get_grass")
