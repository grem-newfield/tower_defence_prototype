extends Node3D

func _on_area_3d_area_shape_entered(area_rid:RID, area:Area3D, area_shape_index:int, local_shape_index:int) -> void:
	print_debug("cuz you got that")
	print_debug(str(area_rid))
	print_debug(str(area))
	print_debug(str(area_shape_index))
	print_debug(str(local_shape_index)+"\n")

func subscribe() -> void:
	pass


func _ready() -> void:
	subscribe()
