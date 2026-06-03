extends Node

@onready var player: Node = $"../RTSPlayer"

signal unit_death(unit: CharacterBody3D)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for unit in (get_children() as Array[CharacterBody3D]):
		if unit.player_owner != player:
			unit.startAI()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for unit in (get_children() as Array[CharacterBody3D]):
		if unit.player_owner != player:
			unit.runAI(delta)

func _on_child_entered_tree(node: Node) -> void:
	var death_signal: Signal = node.death
	death_signal.connect(func () -> void:
		unit_death.emit(node)
		remove_child(node)
	)
