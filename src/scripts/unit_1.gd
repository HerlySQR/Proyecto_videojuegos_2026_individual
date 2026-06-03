extends CharacterBody3D

signal death

const MOVE_SPEED: float = 12.0
const LERP_VALUE: float = 0.15
const MELEE_RANGE: float = 1.5
const MELEE_RANGE_SQ: float = MELEE_RANGE ** 2

enum State {
	IDLE,
	MOVE,
	ATTACK
}

var player_owner: Node = null
var current_state: State = State.IDLE
var new_path_goal: Vector3 = Vector3.ZERO
var current_target: CharacterBody3D = null
var health: float = 100.
var damage: float = 10.
var color: Color = Color.RED:
	set(new_color):
		if _material == null:
			_material = StandardMaterial3D.new()
			_material.vertex_color_use_as_albedo = true
			body.material_override = _material
		
		color = new_color
		_material.albedo_color = new_color
	get():
		return color

var _material: StandardMaterial3D

@onready var circle_selection: Sprite3D = $CircleSelection
@onready var obj_selection_aabb: MeshInstance3D = $SelectionAABB
@onready var body: MeshInstance3D = $Armature/Skeleton3D/body
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var armature: Node3D = $Armature
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var units: Node = $".."

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
	if !navigation_agent.is_navigation_finished():
		current_state = State.MOVE
	elif attacking > 0:
		current_state = State.ATTACK
	else:
		current_state = State.IDLE
	
	if health <= 0:
		emit_signal("death")
		units.remove_child(self)
		queue_free()

var attacking = 0

func _unhandled_input(event: InputEvent) -> void:
	if not selected:
		return

	if current_state != State.ATTACK and Input.is_action_just_pressed(&"Input_action_attack"):
		stop_moving()
		attacking = 30
		
		var possible_targets: Array[Node3D] = []
		for unit: Node3D in units.get_children():
			if unit != self and unit.position.distance_squared_to(position) <= MELEE_RANGE_SQ:
				possible_targets.append(unit)
		
		current_target = possible_targets.pick_random()
		if current_target != null:
			face_direction(current_target.position)

func _physics_process(delta: float) -> void:
	if !navigation_agent.is_navigation_finished():
		follow_path(delta)
	else:
		if attacking > 0:
			animation_tree.set("parameters/BlendSpace2D/blend_position", Vector2(0, 1))
		else:
			animation_tree.set("parameters/BlendSpace2D/blend_position", Vector2(0, 0))
	attacking -= 1
	if current_state == State.ATTACK and attacking == 15:
		deal_damage()

func deal_damage(target: CharacterBody3D = current_target) -> void:
	if target != null:
		target.health -= damage

func stop_moving() -> void:
	if current_state == State.MOVE:
		navigation_agent.target_position = position

func follow_path(delta: float) -> void:
	var target_pos = navigation_agent.get_next_path_position()
	var direction = global_position.direction_to(target_pos)
	face_direction(target_pos)
	
	velocity = direction * MOVE_SPEED
	move_and_slide()
	
	animation_tree.set("parameters/BlendSpace2D/blend_position", Vector2(1, 0))

func face_direction(direction: Vector3) -> void:
	look_at(Vector3(direction.x, global_position.y, direction.z), Vector3.UP)

func new_path(where_to: Vector3) -> void:
	navigation_agent.target_position = where_to

func _startup() -> void:
	selected = false
	
	#obj_selection_aabb.mesh = BoxMesh.new()
	#var selection_aabb: AABB = global_transform * (body.mesh.get_aabb())
	#var aabb_center: Vector3 = selection_aabb.position + selection_aabb.size*0.5
	
	#obj_selection_aabb.mesh.size = selection_aabb.size
	#obj_selection_aabb.position = aabb_center
	
	var aabb = body.get_mesh().get_aabb()
	var box_shape = BoxShape3D.new()
	box_shape.size = aabb.size
	collision_shape.shape = box_shape
	collision_shape.position = aabb.position + aabb.size * 0.5
	
	obj_selection_aabb.queue_free()
	
