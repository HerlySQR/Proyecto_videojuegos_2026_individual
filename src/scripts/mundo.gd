extends Node3D

@onready var player: Node = $RTSPlayer
@onready var units: Node = $Units

"""
@onready var FOW: Control = $RtsFowTexture

var world_to_fow_texture_scale_ratio: float
var _map_size: Vector2
var FOW_Texture: ImageTexture

func fow_initialize(new_texture_size: Vector2i) -> void:
	world_to_fow_texture_scale_ratio = float(new_texture_size.x) / float(_map_size.x)
	FOW.new_fow(new_texture_size)
	FOW.fow_updated.connect(
		func () -> void:
			FOW_Texture = FOW.fow_viewport_texture
			(navigation_map_parts_treenode.get_child(0).get_material_override() as ShaderMaterial).set_shader_parameter("source_texture_fow", FOW_Texture)
			debug_fow.texture = FOW_Texture
			for unit: Node3D in dynamic_objects_list.keys():
				_object3D_fow_update(unit, "unit")
			for building: Node3D in static_objects_list.keys():
				_object3D_fow_update(building, "building")
	)

func _ready() -> void:
	set_physics_process(false)
	_map_size = Vector2(map.scale.x, map.scale.z)
	fow_initialize(Vector2i(128, 128))


const RTS_FOW = preload("res://src/scenes/rts_fow.tscn")
const FOW_VISIBILITY_WHEN_EXPLORED = 0.1
const CULLING_CAMERA_FOV_EXTRA_MARGIN = 0.0

var world_objects: Array[MeshInstance3D] = []

var map_fow_object_dissolvers_dict: Dictionary[int, MeshInstance3D]
var map_fow_object_dissolvers_array: Array[MeshInstance3D]
var map_fow_explored_areas_texture_image: Image
var map_objects_dict: Dictionary[int, MeshInstance3D]
var map_objects_array: Array[MeshInstance3D]
var map_processor_delta: float
var map_processor_needs_update_fow_array: bool
var map_processor_timer_fow_array: float
var map_processor_timer_fow_update: float
var map_processor_grid_sync_to_objects: float
var map_expanded_culling_camera: Camera3D = Camera3D.new()

@onready var map_terrain: MeshInstance3D = $NavigationRegion3D2/Grass
@onready var map_size: int = int(map_terrain.get_mesh().get_aabb().size.x)
@onready var map_objects_nodetree: Node = $NavigationRegion3D2/Grass/Trees

@onready var fow_visible_area_sub_viewport: SubViewport = $FowVisibleArea_SubViewport
@onready var fow_visible_area_color_rect: ColorRect = $FowVisibleArea_SubViewport/ColorRect
@onready var fow_visible_area_multi_mesh_instance_2d: MultiMeshInstance2D = $FowVisibleArea_SubViewport/MultiMeshInstance2D
@onready var fow_explored_area_sub_viewport: SubViewport = $FowExploredArea_SubViewport
@onready var fow_explored_area_color_rect: ColorRect = $FowExploredArea_SubViewport/ColorRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_viewport().get_camera_3d().add_child(map_expanded_culling_camera)
	map_expanded_culling_camera.process_mode = Node.PROCESS_MODE_DISABLED
	map_expanded_culling_camera.current = false
	map_expanded_culling_camera.hide()
	
	for node: MeshInstance3D in map_objects_nodetree.get_children():
		world_objects.append(node)
		node.hide()
	
	fow_initialize()
	fow_texture_update(
		map_terrain,
		fow_explored_area_color_rect,
		fow_visible_area_sub_viewport,
		fow_explored_area_sub_viewport
	)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_second_culling_camera()
	process_object_visibility(map_fow_explored_areas_texture_image)
	map_processor_tick(delta)

static func process_object_visibility(fow_final_image_texture: Image) -> void:
	if fow_final_image_texture == null:
		return
	
	var map_culling_camera: Camera3D = Globals.rt

func update_second_culling_camera() -> void:
	var main_camera: Camera3D = get_viewport().get_camera_3d()
	map_expanded_culling_camera.fov = main_camera.fov + CULLING_CAMERA_FOV_EXTRA_MARGIN
	map_expanded_culling_camera.global_transform = main_camera.global_transform
	map_expanded_culling_camera.keep_aspect = main_camera.keep_aspect
"""
