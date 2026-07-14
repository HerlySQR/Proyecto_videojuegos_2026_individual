extends Node

@onready var player: CharacterBody3D = $"../../Units/Hero"
@onready var terrain: MeshInstance3D = $"../../NavigationRegion3D/Terrain"
@onready var fog_plane: MeshInstance3D = $"../FogPlane"

const MAP_SIZE := 400.0
const TEXTURE_SIZE := 512
const VISION_RADIUS := 10.0

var world_min: Vector2
var world_max: Vector2
var visibility_image: Image
var visibility_texture: ImageTexture

func _ready():
	visibility_image = Image.create(
		TEXTURE_SIZE,
		TEXTURE_SIZE,
		false,
		Image.FORMAT_R8
	)

	visibility_image.fill(Color.BLACK)

	visibility_texture = ImageTexture.create_from_image(visibility_image)
	var aabb := terrain.get_aabb()

	var min_corner = terrain.to_global(Vector3(aabb.position.x, 0.0, aabb.position.z))

	var max_corner = terrain.to_global(Vector3(aabb.position.x + aabb.size.x, 0.0, aabb.position.z + aabb.size.z))

	world_min = Vector2(min_corner.x, min_corner.z)
	world_max = Vector2(max_corner.x, max_corner.z)
	
	var mesh := terrain.mesh
	var mat := fog_plane.get_active_material(0)

	if mat is ShaderMaterial:
		mat.set_shader_parameter("visibility_texture", visibility_texture)

func _process(delta):
	visibility_image.fill(Color.BLACK)
	var uv = world_to_tex(player.global_position)
	draw_disc(uv, world_radius_to_pixels(VISION_RADIUS))

	visibility_texture.update(visibility_image)

func world_to_tex(pos: Vector3) -> Vector2i:
	var u := inverse_lerp(world_min.x, world_max.x, pos.x)
	var v := inverse_lerp(world_min.y, world_max.y, pos.z)

	var x := int(u * (TEXTURE_SIZE - 1))
	var y := int(v * (TEXTURE_SIZE - 1))

	return Vector2i(clamp(x, 0, TEXTURE_SIZE - 1), clamp(y, 0, TEXTURE_SIZE - 1))

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

func get_visibility_texture() -> Texture2D:
	return visibility_texture
