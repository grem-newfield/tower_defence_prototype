@tool
extends Node

# When you check this box in the Inspector, it will run the update logic.
@export var run_update: bool = false:
	set(value):
		# Only run if the checkbox is checked (value becomes true).
		if value:
			print("Update triggered by checkbox.")
			if Engine.is_editor_hint():
				# Call the main function.
				update_mesh_instances()
			# Set the variable back to false so the checkbox unchecks itself.
			run_update = false


# Reference to your MeshLibrary (assign in the editor or load it)
@export var mesh_library: MeshLibrary:
	set(value):
		mesh_library = value
		# if Engine.is_editor_hint():
			# update_mesh_instances()  # Update when MeshLibrary is assigned

# func _enter_tree():
#	  if Engine.is_editor_hint():
#		  # Connect to tree_changed signal to detect node changes
#		  if not get_tree().is_connected("tree_changed", Callable(self, "_on_tree_changed")):
#			  get_tree().connect("tree_changed", Callable(self, "_on_tree_changed"))
#
# func _on_tree_changed():
#	  if Engine.is_editor_hint():
#		  update_mesh_instances()  # Update when scene tree changes

func update_mesh_instances():
	if not mesh_library:
		return	# Skip if MeshLibrary is not assigned
	# Find all MeshInstance3D nodes in the scene
	var mesh_instances = find_mesh_instances(get_parent())
	
	for mesh_instance in mesh_instances:
		# Get the MeshInstance3D's name and strip trailing numbers
		var instance_name = mesh_instance.name
		var base_name = strip_trailing_numbers(instance_name)
		# Find the item in the MeshLibrary with the base name
		var item_id = mesh_library.find_item_by_name(base_name)
		if item_id != -1:
			# Assign the mesh from the MeshLibrary to the MeshInstance3D
			mesh_instance.mesh = mesh_library.get_item_mesh(item_id)
		else:
			print("No mesh found in MeshLibrary for base name: ", base_name)

# Helper function to recursively find all MeshInstance3D nodes
func find_mesh_instances(node: Node) -> Array:
	var mesh_instances = []
	if node is MeshInstance3D and not node in mesh_instances:
		mesh_instances.append(node)
	for child in node.get_children():
		var child_instances = find_mesh_instances(child)
		for child_instance in child_instances:
			if not child_instance in mesh_instances:
				mesh_instances.append(child_instance)
	return mesh_instances

# Helper function to strip trailing numbers from a string
func strip_trailing_numbers(node_name: String) -> String:
	var regex = RegEx.new()
	regex.compile("\\d+$")	# Matches one or more digits at the end of the string
	return regex.sub(node_name, "")  # Remove the matched digits
