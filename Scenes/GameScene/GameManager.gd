extends Node

@export var max_waves: int = 5
@export var EnemySpawner: Node

var current_wave: int = 0
var enemies_alive: int = 0

func _ready() -> void:
	SignalBus.creep_spawned.connect(_on_enemy_spawned)
	SignalBus.creep_died.connect(_on_enemy_died)
	start_next_wave()

func start_next_wave():
	if not EnemySpawner:
		push_error("No EnemySpawner exists!")
		get_tree().quit()
	current_wave += 1
	if current_wave > max_waves:
		SignalBus.game_over.emit(true) # WIN
		return
	SignalBus.wave_started.emit(current_wave)
	EnemySpawner.spawn_wave(current_wave)



func _on_enemy_spawned(enemy: Node):
	enemies_alive += 1

func _on_enemy_died(enemy: Node, currency: int):
	enemies_alive -= 1
	if enemies_alive <= 0:
		if enemies_alive < 0:
			push_error("How the fuck is enemies_alive negative?")
			get_tree().quit()
		SignalBus.wave_ended.emit(current_wave, true)
		start_next_wave()


