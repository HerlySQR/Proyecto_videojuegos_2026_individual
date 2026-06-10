extends Sprite3D

@onready var unit: CharacterBody3D = $".."
@onready var progress_bar: TextureProgressBar = $SubViewport/Panel/TextureProgressBar

func _ready() -> void:
	progress_bar.value = unit.health
	progress_bar.max_value = unit.max_health

func _process(delta: float) -> void:
	progress_bar.value = unit.health
	progress_bar.max_value = unit.max_health
