extends Polygon2D

const MAP_SIZE = 130.0
const TEXTURE_SIZE = 512

func world_to_texture(pos: Vector2) -> Vector2:
	return Vector2((pos.x / MAP_SIZE + 0.5) * TEXTURE_SIZE, (pos.y / MAP_SIZE + 0.5) * TEXTURE_SIZE)

func set_visibility(points: PackedVector2Array) -> void:
	var poly := PackedVector2Array()
	for p in points:
		poly.append(world_to_texture(p))
	polygon = poly

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
