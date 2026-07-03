extends Node3D

const NUM_RAYS: = 20
const MAX_DISTANCE: = 10.0

@onready var hero: CharacterBody3D = $"../../Units/Hero"
@onready var terrain: MeshInstance3D = $"../../NavigationRegion3D/Terrain"
@onready var visibility_polygon: Polygon2D = $"../FogViewport/Canvas/VisibilityPolygon"

var visibility_polygon := PackedVector2Array()
var test := []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	calculate_visibility()

func calculate_visibility() -> void:
	visibility_polygon.clear()
	var space = get_world_3d().direct_space_state
	var eye = hero.global_position + Vector3.UP * 1.7
	for i in NUM_RAYS:
		var angle = TAU * float(i) / NUM_RAYS
		var dir = Vector3(
			cos(angle),
			0,
			sin(angle)
		)
		var target = eye + dir * MAX_DISTANCE
		var query = PhysicsRayQueryParameters3D.create(eye, target)
		query.collide_with_areas = false
		query.collide_with_bodies = true
		query.exclude = [hero.get_rid()]
		
		var hit = space.intersect_ray(query)
		var point : Vector3
		if hit.is_empty():
			point = target
		else:
			point = hit.position
			
		visibility_polygon.append(Vector2(point.x, point.z))
