extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_released(&"input_action_enter") or Input.is_action_just_released(&"input_action_mouseclick_left"):
		get_viewport().set_input_as_handled()
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		
	if Input.is_action_just_released(&"input_action_esc"):
		get_viewport().set_input_as_handled()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
