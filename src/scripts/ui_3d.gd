extends Node

const ORDER_EFFECT: PackedScene = preload("res://src/scenes/order_effect.tscn")

static func create_expanding_circle(obj_caller: Node, where: Vector3) -> void:
	var circle: Decal = ORDER_EFFECT.instantiate()
	circle.position = where + Vector3(0, 0.05, 0)
	obj_caller.get_tree().root.add_child(circle)
	_scale_expand_fade_out(circle, Vector3(2, 1, 2), 0.2)
	
static func _scale_expand_fade_out(obj_to_expand: Node3D, expand_to: Vector3, duration: float) -> void:
	obj_to_expand.get_tree().create_tween(
	).tween_property(obj_to_expand, "scale", expand_to, duration).set_trans(
		Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	obj_to_expand.get_tree().create_timer(duration).timeout.connect(func () -> void:
		obj_to_expand.queue_free()
	)
