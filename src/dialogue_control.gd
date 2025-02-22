class_name DialogueControl
extends Node

enum Controls { CONTINUE, PLAYER_INPUT }

signal dialogue_advanced(line: String, controls: Dictionary)
signal last_line_reached

var is_being_prompted: bool = false

@export var dialogue: DialogueResource
@export var dialogue_label: RichTextLabel
@export var player_state: PlayerState

var _current_controls: Dictionary = {}

var _current_line_idx: int = 0:
	set(value):
		_current_line_idx = value
		var line := dialogue.lines[_current_line_idx]
		var controls = {}

		var player_input_parsed = dialogue.get_player_input_from_line(line)
		if player_input_parsed:
			line = player_input_parsed["stripped"]
			controls[Controls.PLAYER_INPUT] = player_input_parsed

		var continue_parsed = dialogue.get_continue_from_line(line)
		if continue_parsed:
			line = continue_parsed["stripped"]
			controls[Controls.CONTINUE] = continue_parsed

		_current_controls = controls
		is_being_prompted = controls.size() > 0
		dialogue_advanced.emit(line, controls)

		if dialogue_label is RichTextLabel:
			dialogue_label.text = line


func advance() -> void:
	var next_line = _current_line_idx + 1
	if next_line > dialogue.lines.size() - 1:
		printerr("End of dialogue")
		last_line_reached.emit()
		return

	_current_line_idx = next_line
	if (
		_current_controls.has(Controls.PLAYER_INPUT)
		and player_state.prompts.has(_current_controls[Controls.PLAYER_INPUT]["name_attr"])
	):
		advance()
		return


func _ready() -> void:
	assert(dialogue is DialogueResource, "DialogueResource not set")
	assert(dialogue_label is RichTextLabel, "RichTextLabel not set")
	assert(player_state is PlayerState, "PlayerState not set")

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
