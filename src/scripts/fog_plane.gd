extends MeshInstance3D

@onready var static_body_3d: StaticBody3D = $"../../NavigationRegion3D/Terrain/StaticBody3D"
var offset := 0.15

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	project_to_terrain()
	print("FogPlane:", global_position)
	print("Terrain:", static_body_3d.global_position)

func project_to_terrain():
	print(mesh)
	print(mesh.get_class())
	var array_mesh := mesh as ArrayMesh
	if array_mesh == null:
		push_error("FogPlane debe usar un ArrayMesh")
		return

	var arrays = array_mesh.surface_get_arrays(0)
	var vertices : PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]

	for i in range(vertices.size()):
		var local := vertices[i]
		var world := global_transform * local

		var query := PhysicsRayQueryParameters3D.create(
			world + Vector3.UP * 500.0,
			world + Vector3.DOWN * 500.0
		)

		query.collide_with_bodies = true
		query.collide_with_areas = false
		
		if i < 5:
			print(local)
			print(world)

		var hit := get_world_3d().direct_space_state.intersect_ray(query)

		if !hit.is_empty():
			if i < 10:
				print("Hit ", i, " -> ", hit.position.y)

		world.y = hit.position.y + offset
		vertices[i] = global_transform.affine_inverse() * world

	arrays[Mesh.ARRAY_VERTEX] = vertices

	var new_mesh := ArrayMesh.new()

	new_mesh.add_surface_from_arrays(
		Mesh.PRIMITIVE_TRIANGLES,
		arrays
	)

	mesh = new_mesh

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
