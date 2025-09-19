extends CharacterBody3D

const LERP_VALUE : float = 0.15

@export var tower_prefab: PackedScene
@export var where_to_place: RayCast3D

var max_health: int = 100
var health: int = max_health

var snap_vector : Vector3 = Vector3.DOWN
var speed : float



@export_group("Movement variables")
@export var walk_speed : float = 3.0
@export var run_speed : float = 5.0
@export var jump_strength : float = 15.0
@export var gravity : float = 50.0

const ANIMATION_BLEND : float = 7.0

@onready var player_mesh : Node3D = $Mesh
@onready var spring_arm_pivot : Node3D = $SpringArmPivot
@onready var animator : AnimationTree = $AnimationTree

func _ready() -> void:
	SignalBus.player_health_changed.connect(take_damage)
	SignalBus.game_over.connect(_on_game_over)

func take_damage(amount: int) -> void:
	health -= amount
	$HUD/TopPanel/MarginContainer/Health.text = "Health: %-3d" % health
	if health <= 0:
		SignalBus.game_over.emit(false)

func _on_game_over(win:bool) -> void:
	if win:
		print("JU VIN")
		get_tree().quit()
	else:
		print("JU LUUZ")
		get_tree().quit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("place_tower"):
		var tower_placement_pos: Variant = get_placement_pos()
		if tower_placement_pos == null: return
		var tower: Node3D = tower_prefab.instantiate()
		tower.position = tower_placement_pos
		get_parent().add_child(tower)
		SignalBus.tower_placed.emit(tower, tower_placement_pos)

func get_placement_pos() -> Variant:
	if where_to_place.is_colliding():
		return where_to_place.get_collision_point()
	return null

func _physics_process(delta: float) -> void:
	var move_direction : Vector3 = Vector3.ZERO
	move_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	move_direction.z = Input.get_action_strength("move_backwards") - Input.get_action_strength("move_forwards")
	move_direction = move_direction.normalized()
	move_direction = move_direction.rotated(Vector3.UP, spring_arm_pivot.rotation.y)
	
	velocity.y -= gravity * delta
	
	if Input.is_action_pressed("run"):
		speed = run_speed
	else:
		speed = walk_speed
	
	velocity.x = move_direction.x * speed
	velocity.z = move_direction.z * speed
	
	if move_direction:
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(velocity.x, velocity.z), LERP_VALUE)
	
	var just_landed := is_on_floor() and snap_vector == Vector3.ZERO
	var is_jumping := is_on_floor() and Input.is_action_just_pressed("jump")
	if is_jumping:
		velocity.y = jump_strength
		snap_vector = Vector3.ZERO
	elif just_landed:
		snap_vector = Vector3.DOWN
	
	apply_floor_snap()
	move_and_slide()
	animate(delta)

func animate(delta):
	if is_on_floor():
		animator.set("parameters/ground_air_transition/transition_request", "grounded")
		
		if velocity.length() > 0:
			if speed == run_speed:
				animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), 1.0, delta * ANIMATION_BLEND))
			else:
				animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), 0.0, delta * ANIMATION_BLEND))
		else:
			animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), -1.0, delta * ANIMATION_BLEND))
	else:
		animator.set("parameters/ground_air_transition/transition_request", "air")
