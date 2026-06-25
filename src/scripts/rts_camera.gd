extends Node3D

const CAMERA_PAN_MARGIN: float = 5.0 # Pixels to trigger pan on the screen edge
const CAMERA_ZOOM_SPEED: float = 1.0
const CAMERA_ZOOM_RANGE: Vector2 = Vector2(50, 200)
const CAMERA_MOVE_SPEED: Vector2 = Vector2(40, 100)
const CAMERA_ROTATION_SPEED: float = 1.0

var cam_movement_velocity: Vector3 = Vector3.ZERO
var cam_zoom_velocity: float = 0.0

@onready var camera_3d: Camera3D = $Camera3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup_camera(camera_3d)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	camera_pan(delta)
	camera_move(delta)
	camera_zoom(delta)
	camera_rotate(delta)
	_apply_movement_velocity()
	_apply_zoom_velocity()
	
func camera_pan(delta: float) -> void:
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CONFINED:
		return
	
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	
	if mouse_pos.x < CAMERA_PAN_MARGIN:
		cam_movement_velocity.x = -1 * delta
	if mouse_pos.y < CAMERA_PAN_MARGIN:
		cam_movement_velocity.z = -1 * delta
	if mouse_pos.x > viewport_size.x - CAMERA_PAN_MARGIN:
		cam_movement_velocity.x = 1 * delta
	if mouse_pos.y > viewport_size.y - CAMERA_PAN_MARGIN:
		cam_movement_velocity.z = 1 * delta

func camera_move(delta: float) -> void:
	if Input.is_action_pressed(&"input_action_camera_forward"):
		cam_movement_velocity.z = -1 * delta
	if Input.is_action_pressed(&"input_action_camera_backward"):
		cam_movement_velocity.z = 1 * delta
	if Input.is_action_pressed(&"input_action_camera_left"):
		cam_movement_velocity.x = -1 * delta
	if Input.is_action_pressed(&"input_action_camera_right"):
		cam_movement_velocity.x = 1 * delta

func camera_rotate(delta: float) -> void:
	if Input.is_action_pressed(&"input_action_rotate_camera_left"):
		global_rotation.y += CAMERA_ROTATION_SPEED * delta
	if Input.is_action_pressed(&"input_action_rotate_camera_right"):
		global_rotation.y -= CAMERA_ROTATION_SPEED * delta

func camera_zoom(delta: float) -> void:
	if Input.is_action_just_released(&"input_camera_zoom_in"):
		cam_zoom_velocity -= (CAMERA_ZOOM_SPEED * 1000) * delta
	if Input.is_action_just_released(&"input_camera_zoom_out"):
		cam_zoom_velocity += (CAMERA_ZOOM_SPEED * 1000) * delta

func _setup_camera(cam: Camera3D) -> void:
	cam.fov = 10.0
	cam.position.y = 3.0
	cam.rotation_degrees.x = -30
	#rotation_degrees.y = -45
	cam.translate_object_local(Vector3(0, 0, 75))

func _apply_movement_velocity() -> void:
	if cam_movement_velocity != Vector3.ZERO:
		var camera_zoom_speed: float = remap(
			camera_3d.position.z,
			CAMERA_ZOOM_RANGE.x, CAMERA_ZOOM_RANGE.y,
			CAMERA_MOVE_SPEED.x, CAMERA_MOVE_SPEED.y
		)
		translate_object_local(camera_zoom_speed * cam_movement_velocity)
		cam_movement_velocity = Vector3.ZERO
		
func _apply_zoom_velocity() -> void:
	if cam_zoom_velocity != 0:
		var calculated_zoom: float = camera_3d.position.z + cam_zoom_velocity
		if (calculated_zoom > CAMERA_ZOOM_RANGE.x) and (calculated_zoom < CAMERA_ZOOM_RANGE.y):
			camera_3d.translate_object_local(Vector3(0, 0, cam_zoom_velocity))
		cam_zoom_velocity = 0
