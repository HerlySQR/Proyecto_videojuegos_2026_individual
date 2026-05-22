extends Node

const DRAGBOX_MIN_AREA: int = 4 # Area values

@onready var ui_dragbox: NinePatchRect = $NinePatchRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ui_dragbox.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func select_obj_by_aabb(obj: CharacterBody3D, mouse_pos: Vector2, camera: Camera3D) -> bool:
	var obj_AABB: AABB = obj.global_transform * obj.body.mesh.get_aabb()
	if obj_AABB.intersects_ray(camera.project_ray_origin(mouse_pos), camera.project_ray_normal(mouse_pos)):
		return true
	return false

func dragbox_select_object(object_list: Array, dragbox_select: Rect2) -> Array[Node3D]:
	var selected_list: Array[Node3D] = []
	for object: Node3D in (object_list as Array[Node3D]):
		var position_in_2d: Vector2 = get_viewport().get_camera_3d().unproject_position(object.global_position)
		if dragbox_select.has_point(position_in_2d):
			selected_list.append(object)
	return selected_list

func update_selection_rectangle(new_rect: Rect2) -> void:
	new_rect = new_rect.abs()
	ui_dragbox.position = new_rect.position
	ui_dragbox.size = new_rect.size
	
	if new_rect.get_area() > DRAGBOX_MIN_AREA:
		ui_dragbox.show()

func dragbox_hide() -> void:
	ui_dragbox.hide()

func _select_object(object: Node) -> void:
	object.selected = true

func _unselect_object(object: Node) -> void:
	object.selected = false

func _toggle_select_object(object: Node) -> void:
	object.selected = !object.selected

func select_array(array: Array[Node3D]) -> void:
	for obj in array:
		_select_object(obj)

func unselect_array(array: Array[Node3D]) -> void:
	for obj in array:
		_unselect_object(obj)
