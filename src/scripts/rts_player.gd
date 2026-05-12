extends Node

const TYPE_RTS_CAMERA: Script = preload("main.gd")
const TYPE_SELECTION_MANAGER: Script = preload("selection_manager.gd")
const UI_3D: Script = preload("ui_3d.gd")

@onready var rts_camera: TYPE_RTS_CAMERA = $RTSCamera
@onready var selection_manager: TYPE_SELECTION_MANAGER = $SelectionManager
@onready var units: Node = $"../Units"

var _mouse_dragbox_start_position: Vector2 = Vector2.ZERO
var _mouse_dragbox_end_position: Vector2 = Vector2.ZERO
var _player_selection: Array[Node3D] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	selection_dragbox()

func get_mouse_position_collision_on_point_of_map() -> Vector3:
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	var camera: Camera3D = get_viewport().get_camera_3d()
	var ray_normal: Vector3 = camera.project_ray_normal(mouse_position)
	
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
	query.from = camera.global_position
	query.to = camera.global_position + ray_normal * camera.far
	
	var collision_ray: Dictionary = camera.get_world_3d().direct_space_state.intersect_ray(query)
	if collision_ray.size():
		return collision_ray.position
	return Vector3.ZERO

func update__player_selection(new_obj_selection: Array[Node3D]) -> void:
	selection_manager.unselect_array(_player_selection)
	_player_selection = new_obj_selection
	selection_manager.select_array(_player_selection)

func move_units_to_mouse() -> void:
	if _player_selection.size() > 0:
		var mouse_collision_on_map: Vector3 = get_mouse_position_collision_on_point_of_map()
		if mouse_collision_on_map != Vector3.ZERO:
			for object: Node3D in _player_selection:
				object.new_path(mouse_collision_on_map)
		UI_3D.create_expanding_circle(self, mouse_collision_on_map)

func selection_dragbox() -> void:
	if Input.is_action_pressed(&"input_action_mouseclick_left"):
		if _mouse_dragbox_start_position == Vector2.ZERO:
			_mouse_dragbox_start_position = get_viewport().get_mouse_position()
			_mouse_dragbox_end_position = _mouse_dragbox_start_position
		_mouse_dragbox_end_position = get_viewport().get_mouse_position()
		selection_manager.update_selection_rectangle(Rect2(_mouse_dragbox_start_position, _mouse_dragbox_end_position - _mouse_dragbox_start_position).abs())
	if Input.is_action_just_released(&"input_action_mouseclick_left"):
		var dragbox_rectangle: Rect2 = Rect2(_mouse_dragbox_start_position, _mouse_dragbox_end_position - _mouse_dragbox_start_position).abs()
		update__player_selection([])
		if dragbox_rectangle.get_area() > selection_manager.DRAGBOX_MIN_AREA:
			update__player_selection(selection_manager.dragbox_select_object(units.get_children(), dragbox_rectangle))
			
			selection_manager.dragbox_hide()
		else:
			for obj: Node3D in units.get_children():
				if selection_manager.select_obj_by_aabb(obj, get_viewport().get_mouse_position(), get_viewport().get_camera_3d()):
					update__player_selection([obj])
					break
		
		_mouse_dragbox_start_position = Vector2.ZERO
		_mouse_dragbox_end_position = Vector2.ZERO

	if Input.is_action_just_released(&"input_action_mouseclick_right"):
		if _player_selection.size() >= 0:
			move_units_to_mouse()
