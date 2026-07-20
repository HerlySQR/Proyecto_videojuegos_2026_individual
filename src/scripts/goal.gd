extends Area3D

@onready var hero: CharacterBody3D = $"../Units/Hero"
@onready var you_win: Label = $YouWin

func _on_body_entered(body: Node3D) -> void:
	if body == hero:
		you_win.visible = true
