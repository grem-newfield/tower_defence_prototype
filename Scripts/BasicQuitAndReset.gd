extends Node

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Quit Game"): get_tree().quit()
	if Input.is_action_just_pressed("Reset Scene"): get_tree().reload_current_scene()
	if Input.is_action_just_pressed("Toggle Mouse Capture"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
