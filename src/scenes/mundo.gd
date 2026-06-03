extends Node3D

@onready var player: Node = $RTSPlayer
@onready var hero: CharacterBody3D = $Units/Hero
@onready var units: Node = $Units

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hero.player_owner = player
	for unit: Node3D in (units.get_children() as Array[Node3D]):
		if unit.player_owner == null:
			unit.color = Color.BLUE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
