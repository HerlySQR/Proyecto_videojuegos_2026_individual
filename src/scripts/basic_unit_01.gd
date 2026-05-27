extends CharacterBody3D


signal death
const MOVE_SPEED: float = 12.0

enum State {
	IDLE,
	MOVE,
	ATTACK
}

var current_state: State = State.IDLE
var new_path_goal: Vector3 = Vector3.ZERO

@onready var circle_selection: Sprite3D = $CircleSelection
@onready var obj_selection_aabb: MeshInstance3D = $SelectionAABB
@onready var body: MeshInstance3D = $Body
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

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
	if !navigation_agent.is_navigation_finished():
		follow_path(delta)

func follow_path(delta: float) -> void:
	var target_pos = navigation_agent.get_next_path_position()
	var direction = global_position.direction_to(target_pos)
	face_direction(target_pos)
	
	velocity = direction * MOVE_SPEED
	move_and_slide()

func face_direction(direction: Vector3) -> void:
	look_at(Vector3(direction.x, global_position.y, direction.z), Vector3.UP)

func new_path(where_to: Vector3) -> void:
	navigation_agent.target_position = where_to

func _startup() -> void:
	selected = false
	
	#obj_selection_aabb.mesh = BoxMesh.new()
	#var selection_aabb: AABB = global_transform * (mesh.get_aabb())
	#var aabb_center: Vector3 = selection_aabb.position + selection_aabb.size*0.5
	
	#obj_selection_aabb.mesh.size = selection_aabb.size
	#obj_selection_aabb.position = aabb_center
	
	var aabb = body.get_mesh().get_aabb()
	var box_shape = BoxShape3D.new()
	box_shape.size = aabb.size
	collision_shape.shape = box_shape
	collision_shape.position = aabb.position + aabb.size * 0.5
	
	obj_selection_aabb.queue_free()
	
