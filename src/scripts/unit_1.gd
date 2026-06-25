extends CharacterBody3D

signal death
signal damaged(source: CharacterBody3D, amount: float)

const LERP_VALUE: float = 0.15
const MELEE_RANGE: float = 2.5
const MELEE_RANGE_SQ: float = MELEE_RANGE ** 2
const MELEE_RANGE_THRESHOLD: float = 3.0
const MELEE_RANGE_THRESHOLD_SQ: float = MELEE_RANGE_THRESHOLD ** 2
const GRAVITY = 20.0

const IDLE_ANIMATION = Vector2(0, 0)
const MOVE_ANIMATION = Vector2(1, 0)
const ATTACK_ANIMATION = Vector2(0, 1)

enum State {
	IDLE,
	MOVE,
	ATTACK
}

var player_owner: Node = null
var current_state: State = State.IDLE
var new_path_goal: Vector3 = Vector3.ZERO
var current_target: CharacterBody3D = null
var health: float = 100.
var max_health: float = 100.
var damage: float = 10.
var move_speed: float = 10.0
var look_direction: = Vector3.ZERO
var current_animation = IDLE_ANIMATION
var desired_animation = IDLE_ANIMATION
var color: Color = Color.RED:
	set(new_color):
		if _material == null:
			_material = StandardMaterial3D.new()
			_material.vertex_color_use_as_albedo = true
			body.material_override = _material
		
		color = new_color
		_material.albedo_color = new_color
	get():
		return color

var _material: StandardMaterial3D

@onready var circle_selection: Decal = $CircleSelection
@onready var obj_selection_aabb: MeshInstance3D = $SelectionAABB
@onready var body: MeshInstance3D = $Armature/Skeleton3D/body
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var armature: Node3D = $Armature
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var units: Node = $".."

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
	_startup()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !navigation_agent.is_navigation_finished():
		current_state = State.MOVE
	elif attacking > 0:
		current_state = State.ATTACK
	else:
		current_state = State.IDLE
	
	if health <= 0:
		emit_signal("death")
		units.remove_child(self)
		queue_free()

var attacking = 0

func _unhandled_input(event: InputEvent) -> void:
	if  Input.is_action_just_pressed(&"input_action_space_bar") and player_owner != null:
		var camera = get_viewport().get_camera_3d()
		var parent: Node3D = camera.get_parent()
		parent.position.x = global_position.x
		parent.position.z = global_position.z + camera.position.z/2
		
	if not selected:
		return

	if current_state != State.ATTACK and Input.is_action_just_pressed(&"Input_action_attack"):
		var possible_targets: Array[Node3D] = []
		for unit: Node3D in units.get_children():
			if unit != self and unit.position.distance_squared_to(position) <= MELEE_RANGE_SQ and unit.player_owner != player_owner:
				possible_targets.append(unit)
		
		current_target = possible_targets.pick_random() if !possible_targets.is_empty() else null
		do_attack()

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity.x = safe_velocity.x
	velocity.z = safe_velocity.z

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	if look_direction.length() > 0.01:
		var target_angle = atan2(
			look_direction.x,
			look_direction.z
		)

		body.rotation.y = lerp_angle(
			body.rotation.y,
			target_angle,
			15.0 * delta
		)

	if !navigation_agent.is_navigation_finished():
		var next_point = navigation_agent.get_next_path_position()
		var dir = next_point - global_position
		face_direction(next_point)
		dir.y = 0

		if dir.length() > 0.1:
			dir = dir.normalized()

			var desired_velocity = dir * move_speed
			navigation_agent.velocity = desired_velocity
		else:
			velocity.x = 0
			velocity.z = 0
		
		move_and_slide()
	
		desired_animation = MOVE_ANIMATION
	else:
		velocity.x = 0
		velocity.z = 0

		if attacking > 0:
			desired_animation = ATTACK_ANIMATION
		else:
			desired_animation = IDLE_ANIMATION

	attacking -= 1
	if current_state == State.ATTACK and attacking == 15:
		deal_damage()
	
	if current_animation != desired_animation:
		current_animation = current_animation.move_toward(desired_animation, LERP_VALUE)
	
	animation_tree.set("parameters/BlendSpace2D/blend_position", current_animation)

func do_attack(target: CharacterBody3D = current_target) -> void:
	stop_moving()
	attacking = 30
	if target != null:
		face_direction(target.position)

func deal_damage(target: CharacterBody3D = current_target) -> void:
	if target != null and position.distance_squared_to(target.position) <= MELEE_RANGE_THRESHOLD_SQ:
		target.health -= damage
		target.damaged.emit(self, damage)

func stop_moving() -> void:
	if current_state == State.MOVE:
		navigation_agent.target_position = position

func face_direction(dir: Vector3) -> void:
	look_direction = dir - global_position

func new_path(where_to: Vector3) -> void:
	navigation_agent.target_position = where_to
	
func order_move(where_to: Vector3) -> void:
	if navigation_agent.target_position.distance_squared_to(where_to) >= 4:
		new_path(where_to)

func _startup() -> void:
	selected = false
	
	#obj_selection_aabb.mesh = BoxMesh.new()
	#var selection_aabb: AABB = global_transform * (body.mesh.get_aabb())
	#var aabb_center: Vector3 = selection_aabb.position + selection_aabb.size*0.5
	#
	#obj_selection_aabb.mesh.size = selection_aabb.size
	#obj_selection_aabb.position = aabb_center
	
	#var aabb = body.get_mesh().get_aabb()
	#var box_shape = BoxShape3D.new()
	#box_shape.size = aabb.size
	#collision_shape.shape = box_shape
	#collision_shape.position = aabb.position + aabb.size * 0.5
	
	obj_selection_aabb.queue_free()

# AI

const HELP_RANGE = 1
const HELP_RANGE_SQ = HELP_RANGE**2
const ORDER_RETURN_RANGE = 40
const ORDER_RETURN_RANGE_SQ = ORDER_RETURN_RANGE**2
const RETURN_RANGE = 20
const RETURN_RANGE_SQ = RETURN_RANGE**2
const SIGHT_RANGE = 6
const SIGHT_RANGE_SQ = SIGHT_RANGE**2
const TIME_TO_PORT = 5
const UPDATE_INTERVAL = 0.5

var return_position: Vector3
var list: Array[CharacterBody3D]
var threats: Array[float]
var camp: Dictionary
var t_status: ThreatStatus
var t_time: float
var attacker_pos: Dictionary = {}

enum ThreatStatus {
	OFF_COMBAT,
	ON_COMBAT,
	RETURNING,
	RETURNED
}

func _swap(key1: int, key2: int) -> void:
	var u = list[key1]
	var r = threats[key1]
	list[key1] = list[key2]
	threats[key1] = threats[key2]
	list[key1].attacker_pos[self] = key1
	list[key2] = u
	threats[key2] = r
	u.attacker_pos[self] = key2

func startAI() -> void:
	move_speed = 9.
	health = 50.
	max_health = 50.
	damage = 5.
	
	return_position = position
	list = []
	threats = []
	t_status = ThreatStatus.OFF_COMBAT
	t_time = 0
	
	var options: Array[CharacterBody3D] = []
	for unit: CharacterBody3D in (units.get_children() as Array[CharacterBody3D]):
		if self != unit and player_owner == null:
			if position.distance_squared_to(unit.position) <= HELP_RANGE_SQ:
				options.append(unit)
	
	var other = options.pick_random() if !options.is_empty() else null
	
	if other != null:
		camp = other.camp
		if camp == null:
			camp = {}
			other.camp = camp
	else:
		camp = {}
	
	camp[self] = true
	
	damaged.connect(func (source: CharacterBody3D, amount: float) -> void:
		if player_owner != source.player_owner and (t_status == ThreatStatus.OFF_COMBAT or t_status == ThreatStatus.ON_COMBAT):
			var key: int
			var old_amount: float = 0
			var b = false
			
			if not source.attacker_pos.has(self):
				list.append(source)
				threats.append(amount)
				key = list.size() - 1
				source.attacker_pos[self] = key
				if t_status == ThreatStatus.OFF_COMBAT:
					t_status = ThreatStatus.ON_COMBAT
				b = true
			else:
				key = source.attacker_pos[self]
				old_amount = threats[key]
			
			var new_amount = maxf(old_amount + amount, 0)
			
			threats[key] = new_amount
			
			var i = 0
			if new_amount > old_amount:
				while true:
					if key-i >= 0:
						if threats[key-i] < new_amount:
							_swap(key-i, key+1-i)
						else:
							break
						i = i + 1
					else:
						break
			elif new_amount < old_amount:
				while true:
					if key+i < list.size():
						if threats[key+i] > new_amount:
							_swap(key+i, key-1+i)
						else:
							break
						i = i + 1
					else:
						break
			
			if b:
				for friend: CharacterBody3D in camp.keys():
					if friend != self and not source.attacker_pos.has(friend) and (friend.t_status == ThreatStatus.OFF_COMBAT or friend.t_status == ThreatStatus.ON_COMBAT):
						friend.list.append(source)
						friend.threats.append(0)
						source.attacker_pos[friend] = friend.list.size() - 1
						if friend.t_status == ThreatStatus.OFF_COMBAT:
							friend.t_status = ThreatStatus.ON_COMBAT
	)

func _camp_command() -> void:
	for npc: CharacterBody3D in camp.keys():
		var status: ThreatStatus = npc.t_status
		if status == ThreatStatus.ON_COMBAT:
			npc.t_status = ThreatStatus.RETURNING
			for i in range(npc.list.size() - 1, -1, -1):
				npc.list[i].attacker_pos.erase(npc)
				npc.list.remove_at(i)
				npc.threats.remove_at(i)
			npc.stop_moving()
			npc.order_move(npc.return_position)
			npc.t_time = TIME_TO_PORT
		elif status == ThreatStatus.RETURNED:
			npc.t_status = ThreatStatus.OFF_COMBAT
			npc.t_time = 0
			npc.stop_moving()

func _attack(other: CharacterBody3D) -> void:
	if position.distance_squared_to(other.position) <= MELEE_RANGE_SQ:
		current_target = other
		do_attack()
	else:
		order_move(other.position)

var interval = 0
func runAI(delta: float) -> void:
	interval += delta
	if interval >= UPDATE_INTERVAL:
		interval = 0
		if t_status == ThreatStatus.OFF_COMBAT:
			for unit: CharacterBody3D in units.get_children():
				if player_owner != unit.player_owner and position.distance_squared_to(unit.position) <= SIGHT_RANGE:
					list.append(unit)
					threats.append(0)
					unit.attacker_pos[self] = list.size() - 1
					t_status = ThreatStatus.ON_COMBAT
		elif t_status == ThreatStatus.ON_COMBAT:
			t_time += UPDATE_INTERVAL
			if position.distance_squared_to(return_position) <= RETURN_RANGE_SQ and list[0] != null:
				var target: CharacterBody3D = list[0]
				if target.position.distance_squared_to(return_position) <= ORDER_RETURN_RANGE_SQ:
					if current_state == State.ATTACK or current_state == State.IDLE:
						_attack(target)
				else:
					_camp_command()
			else:
				_camp_command()
		elif t_status == ThreatStatus.RETURNING:
			if t_time > 0:
				t_time -= UPDATE_INTERVAL
				if position.distance_squared_to(return_position) >= 5:
					order_move(return_position)
				elif current_state != State.MOVE:
					t_status = ThreatStatus.RETURNED
					var b = true
					for other: CharacterBody3D in camp.keys():
						if other.t_status != ThreatStatus.RETURNED:
							b = false
							break
					if b:
						_camp_command()
			else:
				if position.distance_squared_to(return_position) >= 5:
					position = return_position
				t_status = ThreatStatus.RETURNED
				var b = true
				for other: CharacterBody3D in camp.keys():
					if other.t_status != ThreatStatus.RETURNED:
						b = false
						break
				if b:
					_camp_command()

func _on_death() -> void:
	if list != null:
		if t_status == ThreatStatus.RETURNING or t_status == ThreatStatus.RETURNED:
			stop_moving()
		
		for i in range(list.size()):
			list[i].attacker_pos.erase(self)
		
		camp.erase(self)
	else:
		for other in attacker_pos.keys():
			var key = attacker_pos[other]
			for i in range(key, other.list.size()):
				other.list[i].attacker_pos[other] = i-1
			other.list.remove_at(key)
			other.threats.remove_at(key)
