extends InterpolatedCamera

export var default_speed = 10
onready var tracked_entity = get_node(target).owner
onready var ally_indicator = get_parent().get_node("Indicator")

# Called when the node enters the scene tree for the first time.
func _ready():
	tracked_entity.has_camera = true
	reset_speed()

func _process(delta):
	var u_position : Vector2 = unproject_position(tracked_entity.lock_on_target.translation + Vector3.UP * 2)
#	print(OS.window_size - u_position)
	ally_indicator.position = OS.window_size - u_position
		
	if tracked_entity.lock_on_target.get_node("VisibilityNotifier").is_on_screen():
		ally_indicator.position = u_position
	else:
		var space_state = ally_indicator.get_world_2d().direct_space_state
		var origin = DisplayManager.BASE_RESOLUTION * DisplayManager.window_zoom * 0.5
		
		var dir = tracked_entity.lock_on_target.translation - translation
		if dir.dot(transform.basis.z) < 0:
			var result = space_state.intersect_ray(origin, u_position, [], 0x7FFFFFFF, false, true)
			# Tremenda quackeada.
			if not result.empty():
				ally_indicator.position = result.position
		else:
			var result = space_state.intersect_ray(origin, (OS.window_size - u_position) * 100, [], 0x7FFFFFFF, false, true)
			# if pointing the camera almost exaclty away from target, don't update position of indicator:
			# Tremenda quackeada.
			if not result.empty():
				ally_indicator.position = result.position

func _on_sword_fighter_requested_camera(entity):
	$AnimationPlayer.play("switch_player")
	$AnimationPlayer.advance(0)
#	get_tree().paused = true
	tracked_entity.has_camera = false
	tracked_entity = entity
	tracked_entity.has_camera = true
	target = entity.get_node("CameraPointPivot/Position3D").get_path()
#	speed = 3
#	$Timer.start()

func _on_Timer_timeout():
	speed = default_speed
	get_tree().paused = false

func set_pause(value):
	get_tree().paused = value

func reset_speed():
	speed = default_speed
