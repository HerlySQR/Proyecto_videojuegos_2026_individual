extends Node

@onready var player: CharacterBody3D = $"../../Units/Hero"
@onready var terrain: MeshInstance3D = $"../../NavigationRegion3D/Terrain"
@onready var fog_terrain: MeshInstance3D = $"../../FogTerrain"
@onready var trees: Node = $"../../NavigationRegion3D/Trees"

const MAP_SIZE := 400.0
const TEXTURE_SIZE := 512
const VISION_RADIUS := 10.0

var world_min: Vector2
var world_max: Vector2
var visibility_image: Image
var visibility_texture: ImageTexture
var explored_image: Image
var explored_texture: ImageTexture
var fog_objects: Array[MeshInstance3D] = []

func _ready():
	var stack = [trees]
	while stack.size() > 0:
		var current = stack.pop_back()
		for child in current.get_children():
			if child is Node:
				stack.append(child)
				if child is MeshInstance3D:
					fog_objects.append(child)
	
	visibility_image = Image.create(
		TEXTURE_SIZE,
		TEXTURE_SIZE,
		false,
		Image.FORMAT_RGBA8
	)

	explored_image = Image.create(
		TEXTURE_SIZE,
		TEXTURE_SIZE,
		false,
		Image.FORMAT_RGBA8
	)

	visibility_image.fill(Color.BLACK)
	explored_image.fill(Color.BLACK)

	visibility_texture = ImageTexture.create_from_image(visibility_image)
	explored_texture = ImageTexture.create_from_image(explored_image)

	var aabb := terrain.get_aabb()

	var min_corner = terrain.to_global(Vector3(aabb.position.x, 0.0, aabb.position.z))

	var max_corner = terrain.to_global(Vector3(aabb.position.x + aabb.size.x, 0.0, aabb.position.z + aabb.size.z))

	world_min = Vector2(min_corner.x, min_corner.z)
	world_max = Vector2(max_corner.x, max_corner.z)
	
	for i in range(fog_terrain.mesh.get_surface_count()):
		var mat := fog_terrain.get_active_material(i) as ShaderMaterial

		mat.set_shader_parameter("visibility_texture", visibility_texture)
		mat.set_shader_parameter("explored_texture", explored_texture)
		mat.set_shader_parameter("world_min", world_min)
		mat.set_shader_parameter("world_max", world_max)

func _process(delta):
	visibility_image.fill(Color.BLACK)
	var uv = world_to_tex(player.global_position)
	draw_disc(uv, world_radius_to_pixels(VISION_RADIUS))

	visibility_texture.update(visibility_image)
	explored_texture.update(explored_image)
	
	for obj in fog_objects:
		if is_visible_world(obj.global_position):
			obj.visible = true
		elif is_explored_world(obj.global_position):
			obj.visible = true
		else:
			obj.visible = false

	for i in range(fog_terrain.mesh.get_surface_count()):
		var mat := fog_terrain.get_active_material(i) as ShaderMaterial
		mat.set_shader_parameter("visibility_texture", visibility_texture)
		mat.set_shader_parameter("explored_texture", explored_texture)

	#visibility_image.save_png("C:/Users/Herly/Documents/para-la-clase/build/visibility.png")
	#explored_image.save_png("C:/Users/Herly/Documents/para-la-clase/build/explored.png")

func world_to_tex(pos: Vector3) -> Vector2i:
	var u := inverse_lerp(world_min.x, world_max.x, pos.x)
	var v := inverse_lerp(world_min.y, world_max.y, pos.z)

	var x := int(u * (TEXTURE_SIZE - 1))
	var y := int(v * (TEXTURE_SIZE - 1))

	return Vector2i(clamp(x, 0, TEXTURE_SIZE - 1), clamp(y, 0, TEXTURE_SIZE - 1))

func is_visible_world(pos: Vector3) -> bool:
	var tex = world_to_tex(pos)
	return visibility_image.get_pixel(tex.x, tex.y).r > 0.5

func is_explored_world(pos: Vector3) -> bool:
	var tex = world_to_tex(pos)
	return explored_image.get_pixel(tex.x, tex.y).r > 0.5

func world_radius_to_pixels(radius: float) -> int:
	var world_width = world_max.x - world_min.x
	return int(radius / world_width * TEXTURE_SIZE)

func draw_disc(center: Vector2i, radius: int):
	var r2 = radius*radius

	for x in range(center. x - radius, center.x + radius + 1):
		if x<0 or x>=TEXTURE_SIZE:
			continue
		for y in range(center. y - radius, center.y + radius + 1):
			if y<0 or y>=TEXTURE_SIZE:
				continue

			var dx=x-center.x
			var dy=y-center.y

			if dx*dx + dy*dy <= r2:
				visibility_image.set_pixel(x, y, Color.WHITE)
				explored_image.set_pixel(x, y, Color.WHITE)

func get_visibility_texture() -> Texture2D:
	return visibility_texture
