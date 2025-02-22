class_name DialogueControl
extends Node

signal last_line_reached

@export var dialogue: DialogueResource
@export var dialogue_label: RichTextLabel

var _current_line_idx: int = 0:
	set(value):
		_current_line_idx = value
		if dialogue_label is RichTextLabel:
			dialogue_label.text = dialogue.lines[_current_line_idx]


func advance() -> void:
	var next_line = _current_line_idx + 1
	if next_line > dialogue.lines.size() - 1:
		printerr("End of dialogue")
		return
	else:
		last_line_reached.emit()
		_current_line_idx = next_line


func _ready() -> void:
	assert(dialogue is DialogueResource, "DialogueResource not set")
	assert(dialogue_label is RichTextLabel, "RichTextLabel not set")

	dialogue.load()

	dialogue_label.text = dialogue.lines[_current_line_idx]

	return
	# TODO: F U J K Y
	_current_line_idx = 3

	var line := dialogue.lines[_current_line_idx]

	var player_input_parsed = dialogue.get_player_input_from_line(line)
	if player_input_parsed:
		print("Player player_input_parsed found: %s" % player_input_parsed)
		dialogue_label.text = player_input_parsed["stripped"]
	else:
		print("No player player_input_parsed found")

	var continue_parsed = dialogue.get_continue_from_line(
		player_input_parsed["stripped"] if player_input_parsed else line
	)
	if continue_parsed:
		print("Continue found: %s" % continue_parsed)
		dialogue_label.text = continue_parsed["stripped"]
	else:
		print("No continue found")
