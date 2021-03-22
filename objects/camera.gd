extends InterpolatedCamera

export var default_speed = 10
onready var tracked_entity = get_node(target).owner
onready var ally_indicator = get_node("Indicator")
onready var screen_bounds = get_node("ScreenBounds")

# Called when the node enters the scene tree for the first time.
func _ready():
	if tracked_entity is Entity:
		tracked_entity.camera = self
	set_process(false)
	ally_indicator.visible = false
#	reset_speed()
	
#	InputManager.connect("key_changed", self, "receive_input")

#funcs receive_input(pad, key, state):
#	pass
	
#	if key == InputManager.EVADE:
#		if state:
#			set_process(true)
#			ally_indicator.visible = true
#		else:
#			set_process(false)
#			ally_indicator.visible = false
#	pass

func _process(delta):
	var u_position : Vector2 = unproject_position(tracked_entity.lock_on_target.translation + Vector3.UP * 2)
	if tracked_entity.lock_on_target.get_node("VisibilityNotifier").is_on_screen():
		ally_indicator.position = u_position
	else:
		var dot = (tracked_entity.lock_on_target.translation - translation).dot(transform.basis.z)
		if dot <= 0:
			ally_indicator.position = screen_bounds.curve.get_closest_point(u_position)
		else:
			var origin = DisplayManager.BASE_RESOLUTION * DisplayManager.window_zoom * 0.5
			ally_indicator.position = screen_bounds.curve.get_closest_point(origin - u_position)
			
#	if tracked_entity.horizontal_speed > 16.0:
#		$SpeedLinesPivot.visible = true
#		$SpeedLinesPivot.look_at(translation + tracked_entity.velocity, Vector3.UP)
#	else:
#		$SpeedLinesPivot.visible = false

func _on_Timer_timeout():
	speed = default_speed
	get_tree().paused = false

func set_pause(value):
	get_tree().paused = value

func reset_speed():
	speed = default_speed
