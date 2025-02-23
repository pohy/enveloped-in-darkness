class_name AdvanceTexture
extends Node

@export var textures: Array[Texture] = []
@export var target: Node3D


func _ready() -> void:
	assert(target is Node3D, "Target must be a Node3D")
	assert(textures.size() > 0, "Textures must have at least one texture")

	_on_texture_idx_changed(TextureState.current_idx)
	TextureState.idx_changed.connect(_on_texture_idx_changed)


func _on_texture_idx_changed(idx: int) -> void:
	if idx < 0 or idx > textures.size() - 1:
		return

	var texture := textures[idx]

	for child in target.get_children():
		if child is MeshInstance3D:
			var mesh_instance := child as MeshInstance3D
			var material := mesh_instance.get_active_material(0)
			if material is StandardMaterial3D:
				var mat := material as StandardMaterial3D
				mat.albedo_texture = texture
