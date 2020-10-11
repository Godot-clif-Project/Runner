extends WorldObject

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var shake_t = 1.0
var angle = Vector3.RIGHT

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	get_node("/root/Stage/NetworkInterface").add_world_object(name, self)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Model.translation = (angle * (shake_t * 0.03)) * sin(shake_t) * 0.5
	shake_t -= delta * 50
	if shake_t <= 0.0:
		set_process(false)
		$Model.translation = Vector3.ZERO
	pass

func _on_Hurtbox_received_hit(hit, hurtbox):
	receive_hit()
	emit_signal("world_object_event", name, "hit")

func receive_hit():
	angle = angle.rotated(Vector3.UP, rand_range(-PI, PI))
	set_process(true)
	shake_t = 50
	MainManager.current_level.spawn_effect(Hit.VISUAL_EFFECTS.BLUNT, translation, Vector3.ZERO)
	