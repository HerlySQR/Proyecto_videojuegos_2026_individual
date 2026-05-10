extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func create_debug_sphere_at(node_caller: Node, at_pos: Vector3, time: float, color: Color) -> void:
	var sphere: MeshInstance3D = MeshInstance3D.new()
	var debug_sphere_mesh: SphereMesh = SphereMesh.new()
	debug_sphere_mesh.rings = 1
	debug_sphere_mesh.radial_segments = 1
	debug_sphere_mesh.radius = 0.2
	debug_sphere_mesh.height = 0.3
	
	sphere.mesh = debug_sphere_mesh
	sphere.scale *= time
	
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	sphere.set_surface_override_material(0, material)
	sphere.position = at_pos
	node_caller.get_tree().root.add_child(sphere)
	node_caller.get_tree().create_timer(time).timeout.connect(func () -> void:
		sphere.queue_free()
	)
