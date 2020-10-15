extends NetworkedObject

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const COLOR = Color(1, 0.792157, 0.298039)
var shake_t = 0.0
var angle = Vector3.RIGHT
var hp = 1000
var path : Array
var speed = 10.0
var dir : Vector3

onready var navigation = $"../Navigation"
onready var positions = $"../Navigation/Positions".get_children()
onready var target = $"../SwordFighter"

# Called when the node enters the scene tree for the first time.
func _ready():
#	path = $"../Navigation".get_simple_path(translation, $"../Navigation/Position3D".translation)
#	dir = translation.direction_to(path[i] + Vector3.UP)
#	yield(get_tree().create_timer(0.5), "timeout")
	set_process(false)
	InputManager.connect("key_changed", self, "receive_input")
	pass # Replace with function body.

func receive_input(pad, key, state):
	if key == InputManager.START and state:
		
		if not get_tree().has_network_peer():
			start()
		elif get_tree().is_network_server():
			start()
			$"../NetworkInterface".receive_networked_object_event(object_id, "start", [])
			
func start():
	get_node("../AnimationPlayer").play("New Anim")
	$"../StageTimer".start()

func reset():
#		$"../AnimationPlayer".seek(0.0, true)
	$"../StageTimer".stop()
	$"../AnimationPlayer".stop(true)
	$Model.material_override.albedo_color = COLOR
	translation = Vector3.ZERO
	hp = 1000

var i = 0
var pos_i = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
#var prev_pos
func _process(delta):
#	if has_los():
#		dir = translation.direction_to(target.translation + Vector3.UP)
#		translation += dir * delta * speed
#		return
##	prev_pos = translation
#	if i < path.size() - 1:
#		translation += dir * delta * speed
#
#		if translation.distance_squared_to(path[i] + Vector3.UP) < 1.0:
#			i += 1
#			dir = translation.direction_to(path[i] + Vector3.UP)
#	else:
##		path = navigation.get_simple_path(translation, positions[randi() % positions.size() - 1].translation)
##		var rand = rand_range(-2, 2)
##		path = navigation.get_simple_path(translation, positions[pos_i].translation + Vector3(rand, 0.0, rand))
##		path = navigation.get_simple_path(translation, positions[pos_i].translation)
##		pos_i += 1
##		if pos_i > positions.size() -1:
##			pos_i = 0
#		path = navigation.get_simple_path(translation, target.translation)
#		i = 0
##		print((prev_pos - translation).length())
	
	if shake_t > 0.0:
		$Model.translation = (angle * (shake_t * 0.03)) * sin(shake_t) * 0.5
		shake_t -= delta * 50
		if shake_t <= 0.0:
			$Model.translation = Vector3.ZERO
			set_process(false)

func has_los() -> bool:
		var space_state = get_world().direct_space_state
		var result = space_state.intersect_ray(translation, target.translation, [self], 0b00000000000000000011)
		if not result.empty() and result["collider"] is KinematicBody:
			return true
		else:
			return false

func move():
	while i < path.size() - 1:
		print(path[i])
		translation = path[i]
		i += 1
		yield(get_tree().create_timer(0.1), "timeout")

func _on_Hurtbox_received_hit(hit, hurtbox):
	receive_hit(hit.damage)
	emit_signal("networked_object_event", object_id, "receive_hit", [hit.damage])

func receive_hit(damage):
	hp -= damage
		
	var new_color = COLOR.linear_interpolate(Color(0.980392, 0.152941, 0.152941), 1 - hp / 1000.0)
	$Model.material_override.albedo_color = new_color
	angle = angle.rotated(Vector3.UP, rand_range(-PI, PI))
	set_process(true)
	shake_t = 50
	MainManager.current_level.spawn_effect(Hit.VISUAL_EFFECTS.BLUNT, translation, Vector3.ZERO)
	$AudioStreamPlayer3D.play()
	
	if hp <= 0:
		reset()
		emit_signal("networked_object_event", object_id, "reset", [])
	
