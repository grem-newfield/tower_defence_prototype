extends Node

# BASIC
signal wave_started(wave_number: int)
signal wave_ended(wave_number: int, success: bool)
signal tower_placed(tower: Node, position: Vector3)
signal tower_attacked(tower: Node, damage: float)
signal player_health_changed(new_health: int)
signal game_over(win: bool)

# TOWER

# CREEP
signal creep_reached_end(creep: Node)
signal creep_spawned(creep: Node)
signal creep_died(creep: Node, currency: int)

# MORE
signal tower_upgraded(tower: Node, level: int)
