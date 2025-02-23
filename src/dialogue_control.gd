class_name DialogueControl
extends Node

enum Controls { CONTINUE, PLAYER_INPUT }

signal dialogue_advanced(line: String, controls: Dictionary)
signal last_line_reached
signal last_dialogue_reached

# @export var dialogue: DialogueResource
@export var dialouges: Array[DialogueResource]
@export var dialogue_label: RichTextLabel
@export var player_state: PlayerState

@export_group("Dependencies - Audio")
@export var klavesnice_player: LoopingPlayer

var dialogue: DialogueResource:
	get:
		if _current_dialogue_idx < 0 or _current_dialogue_idx > dialouges.size() - 1:
			return DialogueResource.new()

		return dialouges[_current_dialogue_idx]

var _current_controls: Dictionary = {}
var _current_dialogue_idx: int = 0

var _current_line_idx: int = -1:
	set(value):
		_current_line_idx = value

		if value < 0 or value > dialogue.lines.size() - 1:
			return

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
		# When dialogue has controls, we want to switch to BEING_PROMPTED
		# When there are controls no more, we want to switch to IN_DIALOGUE
		# Although, prompting and in dialogue feel like sub-states of dialogue control
		if controls.size() > 0:
			player_state.set_state(PlayerState.States.BEING_PROMPTED)
		else:
			# TODO: How about removing/decoupling the state changes from here and letting the caller handle them?
			player_state.set_state(PlayerState.States.IN_DIALOGUE)
		dialogue_advanced.emit(line, controls)

		if dialogue_label is RichTextLabel:
			dialogue_label.text = line


func advance_line() -> void:
	var next_line_idx = _current_line_idx + 1
	print("Advancing line: %s -> %s" % [_current_line_idx, next_line_idx])
	_current_line_idx = next_line_idx

	if next_line_idx == dialogue.lines.size():
		print("End of dialogue lines")
		# TODO: Do we really want to transition player state here? Should be a signal within the editor
		# player_state.set_state(PlayerState.States.INTERACTING)
		last_line_reached.emit()
		# return

	if next_line_idx > dialogue.lines.size() - 1:
		return

	if (
		_current_controls.has(Controls.PLAYER_INPUT)
		and player_state.prompts.has(_current_controls[Controls.PLAYER_INPUT]["name_attr"])
	):
		# Skip prompt input when the prompt has already been answered
		advance_line()
		return

	dialogue_label.visible_ratio = 0
	var duration_s := 1
	var tween := create_tween().set_parallel(true)
	klavesnice_player.begin(1)
	tween.tween_property(dialogue_label, "visible_ratio", 1, duration_s)


func advance_dialogue() -> void:
	var next_dialogue_idx = _current_dialogue_idx + 1
	print("Advancing dialogue: %s -> %s" % [_current_dialogue_idx, next_dialogue_idx])
	_current_dialogue_idx = next_dialogue_idx

	if next_dialogue_idx == dialouges.size():
		print("End of all dialogues")
		# TODO: Do we really want to transition player state here? Should be a signal within the editor
		# player_state.set_state(PlayerState.States.INTERACTING)
		last_dialogue_reached.emit()
		# return

	if next_dialogue_idx > dialouges.size() - 1:
		return

	_current_line_idx = -1
	advance_line()


func _ready() -> void:
	# assert(dialogue is DialogueResource, "DialogueResource not set")
	assert(dialogue_label is RichTextLabel, "RichTextLabel not set")
	assert(player_state is PlayerState, "PlayerState not set")
	assert(dialouges.size() > 0, "No dialogues set")
	assert(klavesnice_player is LoopingPlayer, "LoopingPlayer not set")

	for dialogue_resource in dialouges:
		dialogue_resource.load()

	dialogue_label.visible = false

	player_state.state_changed.connect(_on_player_state_changed)


func _on_player_state_changed(new_state: PlayerState.States, old_state: PlayerState.States) -> void:
	dialogue_label.visible = (
		new_state == PlayerState.States.IN_DIALOGUE
		or new_state == PlayerState.States.BEING_PROMPTED
	)

	if new_state == PlayerState.States.IN_DIALOGUE:
		if _current_line_idx == -1:
			advance_line()
