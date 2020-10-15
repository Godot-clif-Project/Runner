extends Label

onready var start_time = OS.get_ticks_msec()
var stop_timer = true

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
#	InputManager.connect("key_changed", self, "receive_input")
#	get_node("/root/Stage/NetworkInterface").add_networked_object(name, self)

#func receive_input(pad, key, state):
#	if key == InputManager.START and state:
#
#		if not get_tree().has_network_peer():
#			get_node("../AnimationPlayer").play("New Anim")
#		elif get_tree().is_network_server():
#			get_node("../AnimationPlayer").play("New Anim")

func start():
	start_time = OS.get_ticks_msec()
#	stop_timer = false
	set_process(true)

func stop():
	set_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	if not stop_timer:
	var ticks = OS.get_ticks_msec() - start_time
	var minutes = ticks / 60000
	var seconds = (ticks / 1000) % 60
	var hundreds = (ticks / 10) % 100
	var str_time = "%02d : %02d : %02d" % [minutes, seconds, hundreds]
	text = str_time

func _on_Goal_body_entered(body):
	stop_timer = true
