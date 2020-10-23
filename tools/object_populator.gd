tool
extends Spatial

export var path : NodePath
export var populate = false setget set_populate

func set_populate(value):
	if value:
		for child in get_node(path).get_children():
			var numbers = child.name.substr(child.name.length() - 3)
			var _name = child.name.rstrip(numbers)
			
			if $ResourcePreloader.has_resource(_name):
				var existing_object = $LevelObjects.get_node_or_null(child.name)
				if existing_object != null:
					existing_object.transform = child.transform
				else:
					var node = $ResourcePreloader.get_resource(_name).instance()
					node.transform = child.transform
					$LevelObjects.add_child(node)
					node.set_owner(get_tree().get_edited_scene_root())
					node.name = _name + numbers
