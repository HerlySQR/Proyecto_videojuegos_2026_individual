extends MeshInstance3D

@onready var circle_selection: Sprite3D = $CircleSelection

var selected: bool = false:
	set(new_value):
		selected = new_value
		if selected:
			circle_selection.show()
		else:
			circle_selection.hide()
	get():
		return selected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	selected = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
