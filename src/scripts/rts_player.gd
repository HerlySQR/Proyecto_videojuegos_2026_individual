extends Node

const TYPE_RTS_CAMERA: Script = preload("main.gd")
const TYPE_SELECTION_MANAGER: Script = preload("selection_manager.gd")

@onready var rts_camera: TYPE_RTS_CAMERA = $RTSCamera
@onready var selection_manager: TYPE_SELECTION_MANAGER = $SelectionManager
@onready var units: Node = $"../Units"

var mouse_dragbox_start_position: Vector2 = Vector2.ZERO
var mouse_dragbox_end_position: Vector2 = Vector2.ZERO
var show_dragbox: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	selection_dragbox()

func selection_dragbox() -> void:
	if Input.is_action_pressed(&"input_action_mouseclick_left"):
		if mouse_dragbox_start_position == Vector2.ZERO:
			mouse_dragbox_start_position = get_viewport().get_mouse_position()
			mouse_dragbox_end_position = mouse_dragbox_start_position
		mouse_dragbox_end_position = get_viewport().get_mouse_position()
		selection_manager.update_selection_rectangle(Rect2(mouse_dragbox_start_position, mouse_dragbox_end_position - mouse_dragbox_start_position).abs())
	if Input.is_action_just_released(&"input_action_mouseclick_left"):
		var dragbox_rectangle: Rect2 = Rect2(mouse_dragbox_start_position, mouse_dragbox_end_position - mouse_dragbox_start_position).abs()
		selection_manager.dragbox_select_object(units.get_children(), dragbox_rectangle)
		
		mouse_dragbox_start_position = Vector2.ZERO
		mouse_dragbox_end_position = Vector2.ZERO
		selection_manager.dragbox_hide()
