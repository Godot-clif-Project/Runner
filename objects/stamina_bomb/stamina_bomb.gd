extends Spatial

#signal created(velocity, translation)
#signal consumed_charge
#signal ended

enum {FLYING, ACTIVE, FADE}
const LIFETIME = 10.0
const FADETIME = 2.0

var velocity : Vector3
var gravity = Vector3(0.0, -9.8, 0.0)
var state = FLYING
var charges = 4

var owner_id = null

func _ready():
	$NetworkComponent.create("stamina_bomb", {
			"velocity" : velocity,
			"translation" : translation,
		})

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
		if body is Entity:
			body.heal(1000)
			consume_charge()
			$NetworkComponent.event("consume_charge", [])

func _on_Timer_timeout():
	if state == ACTIVE:
		turn_off()
	else:
		$NetworkComponent.remove_from_networked_objects()
		queue_free()

func consume_charge():
	charges -= 1
	if charges == 0:
		turn_off()
		$NetworkComponent.event("turn_off", [])

func turn_off():
	state = FADE
	$Particles.emitting = false
	$Particles2.emitting = false
	$Timer.start(FADETIME)
