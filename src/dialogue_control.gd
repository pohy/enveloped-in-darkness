class_name DialogueControl
extends Node

signal last_line_reached

@export var dialogue: DialogueResource
@export var dialogue_label: RichTextLabel

var _current_line: int = 0:
	set(value):
		_current_line = value
		if dialogue_label is RichTextLabel:
			dialogue_label.text = dialogue.lines[_current_line]


func advance() -> void:
	var next_line = _current_line + 1
	if next_line > dialogue.lines.size() - 1:
		printerr("End of dialogue")
		return
	else:
		last_line_reached.emit()
		_current_line = next_line


func _ready() -> void:
	assert(dialogue is DialogueResource, "DialogueResource not set")
	assert(dialogue_label is RichTextLabel, "RichTextLabel not set")

	dialogue.load()

	dialogue_label.text = dialogue.lines[_current_line]
