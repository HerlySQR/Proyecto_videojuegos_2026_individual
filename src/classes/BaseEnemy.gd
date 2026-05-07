class_name BaseEnemy extends CharacterBody3D

@export_category("Atributos")
@export var vida: float
@export var damage: float
@export var velocidad: float

func movement(delta: float) -> void:
	pass

func die() -> void:
	pass

func attack(body: CharacterBody3D) -> void:
	pass
