extends Node

@export var creep_scene: PackedScene
@export var creep_path: Path3D
@export var spawn_interval: float = 1.0



func spawn_wave(wave_number: int) -> void:
	var enemy_count: int = wave_number * 2 + 10 # simple scaling
	# TODO: refactor into a table of waves
	for i in range(enemy_count):
		spawn_single_enemy()
		await get_tree().create_timer(spawn_interval).timeout


func spawn_single_enemy() -> void:
	var path_follow: PathFollow3D = PathFollow3D.new()
	path_follow.loop = false
	path_follow.rotation_mode = PathFollow3D.ROTATION_ORIENTED

	var creep: Node3D = creep_scene.instantiate()
	path_follow.add_child(creep)
	creep_path.add_child(path_follow)
	path_follow.progress_ratio = 0.0

	var total_path_len: float= creep_path.curve.get_baked_length()
	var duration: float = total_path_len / creep.move_speed

	# here we tween 0.0 to 1.0 with a ratio based on creep speed
	var tween: Tween = path_follow.create_tween()
	tween.tween_method(
	func(ratio:float)->void: path_follow.progress_ratio = ratio,
	0.0, 1.0, duration
	).set_trans(Tween.TRANS_LINEAR)

	# attach callback to tween so it deletes creep and cleans
	tween.tween_callback(func()->void:
		SignalBus.creep_reached_end.emit(creep)
		# this despawn the creep too, no points awarded
		path_follow.queue_free()
	)

	await get_tree().process_frame
	SignalBus.creep_spawned.emit(creep)

	
