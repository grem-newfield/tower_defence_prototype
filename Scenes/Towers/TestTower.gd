extends Node3D

var damage: float = 20.0
var attack_range: float = 15.0
var attack_speed: float = 1.0
var target: Node3D = null
var time_since_last_attack: float = 0.0 # TODO: refactor into timers

# @onready var detection_area: Area3D = $DetectionArea

func _ready() -> void:
	pass
	# If placed dynamically, emit here or from placement code
	# But we emit from player placement code

func _physics_process(delta: float) -> void:
	if target and target.is_inside_tree():
		time_since_last_attack += delta
		if time_since_last_attack >= (1.0 / attack_speed):
			look_at(target.global_position)
			attack_target()
			time_since_last_attack = 0.0

	else:
		find_target()
	
		# SignalBus.tower_attacked.emit(target, damage * delta)

func find_target() -> void:
	# Simple: find closest enemy within range
	target = null
	var closest_distance:float = attack_range
	var creeps: Array[Node] = get_tree().get_nodes_in_group("Creeps")
	
	for creep: Node3D in creeps:
		var distance: float = global_position.distance_to(creep.global_position)
		if distance < closest_distance:
			closest_distance = distance
			target = creep

func attack_target() -> void:
	if target and target.has_method("take_damage"):
		var damage_dealt: float = damage # Expand with armor perhaps
		target.take_damage(damage_dealt)
		SignalBus.tower_attacked.emit(target, damage_dealt)
		# Optional: Add attack effects here

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Creeps"):
		find_target()

func _on_body_exited(body: Node3D) -> void:
	if body == target:
		find_target()
