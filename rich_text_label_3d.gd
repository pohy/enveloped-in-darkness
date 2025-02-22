@tool
extends Node3D
class_name RichTextLabel3D

@export_multiline var text: String:
	set(value):
		text = value
		if rich_text_label is RichTextLabel:
			rich_text_label.text = value

@export var rich_text_label: RichTextLabel


func _ready() -> void:
	assert(rich_text_label is RichTextLabel, "RichTextLabel not set")
