tool
extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
#	curve.add_point(Vector3(0.0, 0.0, 1.0), Vector3.ZERO, Vector3.ZERO, 0)
#	curve.add_point(Vector3(0.0, 1.0, 0.0), Vector3.ZERO, Vector3.ZERO, 1)
#	curve.add_point(Vector3(0.0, 0.0, -1.0), Vector3.ZERO, Vector3.ZERO, 2)
#	pass # Replace with function body.

onready var ig = $ImmediateGeometry
onready var follow = $Path/PathFollow
onready var path = $Path
onready var balls = $Node.get_children()

#var t = 1.0
func _process(delta):
#	process_ig(delta)
	$Path.curve.set_point_position(0, $Start.translation)
	$Path.curve.set_point_position(1, $End.translation)
	$Path.curve.set_point_out(0, $Position3D.translation)
	$Path.curve.set_point_in(1, $Position3D2.translation)
#	_processA(delta)
	
	for i in balls.size():
		$Node.get_child(i).translation = $Path.curve.interpolate(0, $Path/PathFollow.unit_offset * (i / float(balls.size() - 1)))
		
#		i += 1
#	_processX(delta)
#	$MeshInstance.translation = $Path.curve.interpolate(0, 0.5)
#	t += delta * 0.5
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _processA(delta):
	for i in $rope_export/Armature001/Skeleton.get_bone_count() - 1:
		$rope_export/Armature001/Skeleton.set_bone_rest(i, Transform.IDENTITY)
		$rope_export/Armature001/Skeleton.set_bone_pose(i, Transform.IDENTITY.translated(path.curve.interpolate(i, i / 17.0)))

var n = 64
const SIZE = 0.05
func process_ig(delta):
#	# Clean up before drawing.
	ig.clear()
#
#	ig.begin(Mesh.PRIMITIVE_POINTS)
#	for i in n:
#		var pos = path.curve.interpolate(0, follow.unit_offset * (i / float(n)))
#		ig.add_vertex(pos)
		
	ig.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in n:
		var pos = path.curve.interpolate(0, follow.unit_offset * (i / float(n)))
		var next_pos = path.curve.interpolate(0, follow.unit_offset * ((i + 1.0) / float(n)))
		ig.set_normal(Vector3(1, 0, 0))
		ig.add_vertex(pos + Vector3(SIZE,0.0,0))
		ig.add_vertex(pos + Vector3(SIZE,SIZE,0))
		ig.add_vertex(next_pos + Vector3(SIZE,0.0,0.0))

		ig.set_normal(Vector3(1, 0, 0))
		ig.add_vertex(pos + Vector3(SIZE,SIZE,0))
		ig.add_vertex(next_pos + Vector3(SIZE,SIZE,0))
		ig.add_vertex(next_pos + Vector3(SIZE,0.0,0.0))

		ig.set_normal(Vector3(0, 1, 0))
		ig.add_vertex(pos + Vector3(0,SIZE,0))
		ig.add_vertex(next_pos + Vector3(SIZE,SIZE,0.0))
		ig.add_vertex(pos + Vector3(SIZE,SIZE,0))

		ig.set_normal(Vector3(0, 1, 0))
		ig.add_vertex(pos + Vector3(0,SIZE,0))
		ig.add_vertex(next_pos + Vector3(0,SIZE,0.0))
		ig.add_vertex(next_pos + Vector3(SIZE,SIZE,0))

		ig.set_normal(Vector3(-1, 0, 0))
		ig.add_vertex(pos + Vector3(0,SIZE,0))
		ig.add_vertex(pos + Vector3(0,0.0,0))
		ig.add_vertex(next_pos + Vector3(0,0.0,0.0))

		ig.set_normal(Vector3(-1, 0, 0))
		ig.add_vertex(pos + Vector3(0,SIZE,0))
		ig.add_vertex(next_pos + Vector3(0,0.0,0.0))
		ig.add_vertex(next_pos + Vector3(0,SIZE,0))

		ig.set_normal(Vector3(0, -1, 0))
		ig.add_vertex(pos + Vector3(0,0,0))
		ig.add_vertex(pos + Vector3(SIZE,0,0))
		ig.add_vertex(next_pos + Vector3(0,0,0))

		ig.set_normal(Vector3(0, -1, 0))
		ig.add_vertex(pos + Vector3(SIZE,0,0))
		ig.add_vertex(next_pos + Vector3(SIZE,0,0))
		ig.add_vertex(next_pos + Vector3(0,0,0))
#
	ig.end()
