extends Node3D

@onready var marker: Marker3D = $Cube/Marker3D
@onready var attach_point: Marker3D = $AttachPoint
@onready var cube: MeshInstance3D = $Cube

var holder: CharacterBody3D
var damage: float
var cooldown = 0.

const BULLET = preload("res://src/scenes/Bullet.tscn")
const COOLDOWN = 1.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cube.position -= attach_point.position

func initialize(new_holder: CharacterBody3D) -> void:
	holder = new_holder

func shoot() -> void:
	if cooldown <= 0:
		cooldown = COOLDOWN
		var bullet = BULLET.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = marker.global_position
		bullet.global_rotation = holder.global_rotation
		bullet.direction = holder.transform.basis.z.normalized()
		bullet.hitted.connect(func (target: CharacterBody3D) -> void:
			holder.deal_damage(target)
		)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	cooldown -= delta
