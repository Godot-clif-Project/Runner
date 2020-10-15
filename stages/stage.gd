extends Spatial

const EFFECTS = {
	Hit.VISUAL_EFFECTS.BLUNT : preload("res://effects/hit/hit_effect.tscn"),
#	Hit.VISUAL_EFFECTS.PARRY : preload("res://effects/hit_effect_2/hit_effect_parry.tscn"),
#	Hit.VISUAL_EFFECTS.GUARD_BREAK : preload("res://effects/hit_effect_2/hit_effect_parry.tscn"),
#	Hit.VISUAL_EFFECTS.SHOT : preload("res://effects/hit_effect.tscn"),
#	Hit.VISUAL_EFFECTS.SLASH : preload("res://effects/hit_effect_sword/hit_effect_sword.tscn"),
#	Hit.VISUAL_EFFECTS.FIRE : preload("res://effects/hit_effect_fire.tscn"),
	}

# Called when the node enters the scene tree for the first time.
func _ready():
	MainManager.current_level = self

func create_object(resource_name : String, args : Dictionary):
	var new_object = $ResourcePreloader.get_resource(resource_name).instance()
	for key in args.keys():
		new_object.set(key, args[key])
	add_child(new_object)

func spawn_effect(effect_type, p_position, direction):
	if effect_type == null:
		return
		
	var effect_node = EFFECTS[effect_type].instance()
#	effect_node.set_position(p_position + Vector2(floor(rand_range(-10, 10)), floor(rand_range(-10, 10))))
	effect_node.translation = p_position
#	effect_node.scale.x = direction
	add_child(effect_node)
