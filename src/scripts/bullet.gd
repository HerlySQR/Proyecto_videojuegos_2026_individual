extends Area3D

@export var direction: Vector3
var speed = 50
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

signal hitted(target: CharacterBody3D)

func _ready() -> void:
	get_tree().create_timer(2).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	if not direction:
		return
	
	global_position += direction * speed * delta

func _on_area_entered(area: Area3D) -> void:
	queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		hitted.emit(body)
	queue_free()
