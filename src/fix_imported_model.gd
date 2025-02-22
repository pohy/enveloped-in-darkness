@tool
extends Node3D


func _ready() -> void:
	for child in get_children():
		if child is MeshInstance3D:
			var mesh_instance := child as MeshInstance3D
			var material := mesh_instance.get_active_material(0)
			if material is StandardMaterial3D:
				var mat := material as StandardMaterial3D
				mat.flags_unshaded = true
