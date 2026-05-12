extends MeshInstance3D

const SCRIPT_OBJ_DATA: = preload("res://src/scripts/obj_data_consts.gd")
const SCRIPT_OBJ_DATA_MANAGER = preload("res://src/scripts/obj_data_manager.gd")

const MOVE_SPEED: float = 12.0

const _ACT_CONSTS: = SCRIPT_OBJ_DATA.ACTION_NAMES
const _DATA_ENUMS: = SCRIPT_OBJ_DATA.DATA_ENUMS

const OBJ_ACTIONS: Array[Script] = [
	
]

var obj_data: Dictionary = {}

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

var path: PackedVector3Array = []
var _current_path_index: int
var _move_to_path: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_startup()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if _move_to_path:
		follow_path(delta)

func new_path(where_to: Vector3) -> void:
	where_to.y = 0
	
	const ri: float = 2
	where_to.x += randf_range(-ri, ri)
	where_to.z += randf_range(-ri, ri)
	
	path = NavigationServer3D.map_get_path(get_world_3d().get_navigation_map(), global_position, where_to, true)
	_current_path_index = 0
	_move_to_path = true
	
	#Globals.create_debug_sphere_at(self, global_position, 3.0, Color(0.7, 0, 0))
	
	#for point: Vector3 in path:
		#Globals.create_debug_sphere_at(self, point, 1.5, Color(0, 0.8, 0.8))

func follow_path(delta: float) -> void:
	if path.size() == 0:
		_move_to_path = false
		return
	
	var next_path_point: Vector3 = path[_current_path_index]
	next_path_point.y = 0
	var direction_to_next_point: Vector3 = (next_path_point - global_position).normalized()
	#Globals.create_debug_sphere_at(self, global_position, 1.0, Color(0, 0.4, 0))
	global_position += (direction_to_next_point * MOVE_SPEED) * delta
	look_at(next_path_point)
	
	if global_position.distance_squared_to(next_path_point) < 1:
		_current_path_index += 1
		#Globals.create_debug_sphere_at(self, next_path_point, 2.0, Color(0, 0, 0.7))
		
		if _current_path_index >= path.size():
			path.clear()

func _startup() -> void:
	selected = false
	
	#obj_selection_aabb.mesh = BoxMesh.new()
	#var selection_aabb: AABB = global_transform * (mesh.get_aabb())
	#var aabb_center: Vector3 = selection_aabb.position + selection_aabb.size*0.5
	
	#obj_selection_aabb.mesh.size = selection_aabb.size
	#obj_selection_aabb.position = aabb_center
	
	obj_selection_aabb.queue_free()
	
