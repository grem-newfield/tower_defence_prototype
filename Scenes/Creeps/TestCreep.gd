extends Node3D

var max_health: float = 100.0
var health: float = max_health
var currency_reward: int = 10
var move_speed: float = 6.0
var damage: float = 10.0

@onready var path_follow: PathFollow3D = get_parent()

# func _ready() -> void:
	# if path_follow:

func _process(delta: float) -> void:
	if path_follow:
		path_follow.progress += delta * move_speed

func take_damage(damage: float)->void:
	health -= damage
	if health <= 0: die()

func die()->void:
	SignalBus.creep_died.emit(self, currency_reward)
	if path_follow and path_follow.get_parent():
		path_follow.get_parent().remove_child(path_follow)
		path_follow.queue_free()
	queue_free()

func get_global_positiob() -> Vector3:
	return global_position

func despawn()->void:
	queue_free()

