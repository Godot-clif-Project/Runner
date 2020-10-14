extends Spatial

enum {FLYING, ACTIVE, FADE}
const LIFETIME = 6.0
const FADETIME = 2.0

var velocity : Vector3
var gravity = Vector3(0.0, -9.8, 0.0)
var state = FLYING
var charges = 4

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if state == FLYING:
		velocity += gravity * delta * 2
		translation += velocity * delta
	elif state == FADE:
		$MeshInstance.scale -= (Vector3.ONE / FADETIME) * delta
#	elif state == ACTIVE:
#		$Particles.amount = floor(lerp(32, 0, $Timer.time_left / LIFETIME))
#		$Particles.amount -= delta
#		print(floor(lerp(0, 32, $Timer.time_left / LIFETIME)))
	pass

func _on_Collision_body_entered(body):
	$Buff.monitoring = true
	$Collision.set_deferred("monitoring", false)
	$Particles.emitting = true
	$Particles2.emitting = true
	state = ACTIVE
	$Timer.start(LIFETIME)

func _on_Buff_body_entered(body):
	if state == ACTIVE:
		body.get_healing_grass(1000, null)
		charges -= 1
		if charges == 0:
			turn_off()

func _on_Timer_timeout():
	if state == ACTIVE:
		turn_off()
	else:
		queue_free()

func turn_off():
	state = FADE
	$Particles.emitting = false
	$Particles2.emitting = false
	$Timer.start(FADETIME)
