extends MeshInstance3D

@onready var terrain: MeshInstance3D = $"../NavigationRegion3D/Terrain"

func _ready():
	mesh = terrain.mesh
	global_transform = terrain.global_transform
	
	global_position.y += 0.03
	
	var m := mesh.duplicate()
	mesh = m
	
	for i in range(mesh.get_surface_count()):
		var mat = mesh.surface_get_material(i)
		mesh.surface_set_material(i, mat.duplicate())
