extends Node

const TYPE_RTS_CAMERA: Script = preload("main.gd")
const TYPE_SELECTION_MANAGER: Script = preload("selection_manager.gd")

@onready var rts_camera: TYPE_RTS_CAMERA = $RTSCamera
@onready var selection_manager: TYPE_SELECTION_MANAGER = $SelectionManager
@onready var units: Node = $"../Units"

var _mouse_dragbox_start_position: Vector2 = Vector2.ZERO
var _mouse_dragbox_end_position: Vector2 = Vector2.ZERO
var player_selection: Array[Node3D] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	selection_dragbox()

func update_player_selection(new_obj_selection: Array[Node3D]) -> void:
	selection_manager.unselect_array(player_selection)
	player_selection = new_obj_selection
	selection_manager.select_array(player_selection)

func selection_dragbox() -> void:
	if Input.is_action_pressed(&"input_action_mouseclick_left"):
		if _mouse_dragbox_start_position == Vector2.ZERO:
			_mouse_dragbox_start_position = get_viewport().get_mouse_position()
			_mouse_dragbox_end_position = _mouse_dragbox_start_position
		_mouse_dragbox_end_position = get_viewport().get_mouse_position()
		selection_manager.update_selection_rectangle(Rect2(_mouse_dragbox_start_position, _mouse_dragbox_end_position - _mouse_dragbox_start_position).abs())
	if Input.is_action_just_released(&"input_action_mouseclick_left"):
		var dragbox_rectangle: Rect2 = Rect2(_mouse_dragbox_start_position, _mouse_dragbox_end_position - _mouse_dragbox_start_position).abs()
		update_player_selection([])
		if dragbox_rectangle.get_area() > selection_manager.DRAGBOX_MIN_AREA:
			update_player_selection(selection_manager.dragbox_select_object(units.get_children(), dragbox_rectangle))
			
			selection_manager.dragbox_hide()
		else:
			for obj: Node3D in units.get_children():
				if selection_manager.select_obj_by_aabb(obj, get_viewport().get_mouse_position(), get_viewport().get_camera_3d()):
					update_player_selection([obj])
					break
		
		_mouse_dragbox_start_position = Vector2.ZERO
		_mouse_dragbox_end_position = Vector2.ZERO
