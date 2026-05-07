extends MeshInstance3D

@onready var circle_selection: Sprite3D = $CircleSelection
@onready var obj_selection_aabb: MeshInstance3D = $SelectionAABB

var selected: bool = false:
	set(new_value):
		selected = new_value
		if selected:
			circle_selection.show()
		else:
			circle_selection.hide()
	get():
		return selected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_startup()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _startup() -> void:
	selected = false
	
	#obj_selection_aabb.mesh = BoxMesh.new()
	#var selection_aabb: AABB = global_transform * (mesh.get_aabb())
	#var aabb_center: Vector3 = selection_aabb.position + selection_aabb.size*0.5
	
	#obj_selection_aabb.mesh.size = selection_aabb.size
	#obj_selection_aabb.position = aabb_center
	
	obj_selection_aabb.queue_free()
	
