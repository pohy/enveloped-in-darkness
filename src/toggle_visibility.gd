class_name ToggleVisibility
extends Node

@export var target: Node3D
@export var initial_visibility: bool = true


func _ready():
	assert(target is Node3D, "Target not set")
	target.visible = initial_visibility


func toggle():
	target.visible = not target.visible


func set_visibility(visibility: bool):
	target.visible = visibility


func make_visible():
	target.visible = true


func make_invisible():
	target.visible = false
