extends Node

signal unit_death(unit: CharacterBody3D)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_child_entered_tree(node: Node) -> void:
	var death_signal: Signal = node.death
	death_signal.connect(func () -> void:
		unit_death.emit(node)
		remove_child(node)
	)
