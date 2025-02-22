class_name DialogueControl
extends Node

enum Controls { CONTINUE, PLAYER_INPUT }

signal dialogue_advanced(line: String, controls: Dictionary)
signal last_line_reached

@export var dialogue: DialogueResource
@export var dialogue_label: RichTextLabel
@export var player_state: PlayerState

var _current_controls: Dictionary = {}

var _current_line_idx: int = -1:
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
		if controls.size() > 0:
			player_state.set_state(PlayerState.States.BEING_PROMPTED)
		else:
			player_state.set_state(PlayerState.States.IN_DIALOGUE)
		dialogue_advanced.emit(line, controls)

		if dialogue_label is RichTextLabel:
			dialogue_label.text = line


func advance() -> void:
	var next_line = _current_line_idx + 1
	if next_line > dialogue.lines.size() - 1:
		print("End of dialogue")
		last_line_reached.emit()
		# TODO: Do we really want to transition player state here?
		player_state.set_state(PlayerState.States.INTERACTING)
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
	# advance()

	dialogue_label.visible = false

	# dialogue_label.text = dialogue.lines[_current_line_idx]
	player_state.state_changed.connect(_on_player_state_changed)


func _on_player_state_changed(new_state: PlayerState.States, old_state: PlayerState.States) -> void:
	if new_state == PlayerState.States.IN_DIALOGUE:
		dialogue_label.visible = true
		if _current_line_idx == -1:
			advance()
	else:
		dialogue_label.visible = false

		# advance()
