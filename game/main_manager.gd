extends Node

enum collision_layers {LAYER_1, LAYER_2,}

var time = 0

#const TRAINING_ROOM = preload("res://levels/training/training_room_2.tscn")
const LOBBY = preload("res://stages/lobby.tscn")

var current_level : Node
var camera : Camera2D setget set_camera

func set_camera(value : Camera2D) -> void:
	camera = value
	if current_level:
		current_level.camera = value

func _ready() -> void:
	pause_mode = PAUSE_MODE_PROCESS
#	InputManager.connect("key_changed", self, "recieved_input")

func _physics_process(delta):
	if not get_tree().paused:
		time += 1
#	print(time)

#func recieved_input(pad : int, key : String, state : int) -> void:
	# must_pause
	# TODO: HITBOXES WON'T REGISTER HITS IF PAUSING ON THE SAME FRAME WHEN THEY COLLIDE

#		if get_tree().paused != false:
#			get_tree().paused = false
#			InputManager.emit_released_signal()
#		else:
#			get_tree().paused = true

func connect_signal(origin_object, signal_name, target_object, target_function):
	if target_object != null:
		origin_object.connect(signal_name, target_object, target_function)

# Pause game when out of focus
#func _notification(what : int) -> void:
#	if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
#		print("focus in")
#		if current_level != null:
#			current_level.focus_in()
#		get_tree().paused = false
##		InputManager.reset_pads()
##		InputManager.emit_released_signal()
#	if what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
#		print("focus out")
#		if current_level != null:
#			current_level.focus_out()
#		get_tree().paused = true

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	if event.is_action_pressed("ui_capture"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event.is_action_pressed("lobby"):
		if NetworkManager.get_my_id() == 1:
			NetworkManager.rpc("return_to_lobby")
		elif NetworkManager.get_my_id() == 0:
			change_level(LOBBY)
		
#	if event.is_action_pressed("debug_reset"):
#		current_level.reset()
#		current_level.queue_free()
#		get_tree().root.add_child(TRAINING_ROOM.instance())

func change_level(level):
	var level_container = current_level.get_parent()
	current_level.queue_free()
#	level_container.add_child(load(level).instance())
	level_container.add_child(level.instance())

func level_exited():
	pass

func camera_exited():
	pass
