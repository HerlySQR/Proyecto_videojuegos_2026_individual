extends BaseEnemy

@onready var player: CharacterBody3D = $"../player"

func _physics_process(delta: float) -> void:
	if player != null:
		movement(delta)

func movement(delta: float) -> void:
	var directionTo = player.global_position - global_position
	var direction = (transform.basis * Vector3(directionTo.x, 0, directionTo.z)).normalized()
	
	if direction:
		velocity = direction * delta * velocidad
	else:
		velocity.x = move_toward(velocity.x, 0, velocidad)
		velocity.z = move_toward(velocity.z, 0, velocidad)
	
	if not is_on_floor():
		velocity = get_gravity() * delta
		
	move_and_slide()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "player":
		player = body


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "player":
		player = null
