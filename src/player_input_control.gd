extends TextEdit

@export var dialogue_control: DialogueControl
@export var player_state: PlayerState

@export_category("Dependencies - Audio")
@export var klavesnice_player: LoopingPlayer
@export var confirm_player: AudioStreamPlayer


func _ready() -> void:
	assert(dialogue_control is DialogueControl, "DialogueControl not set")
	assert(player_state is PlayerState, "PlayerState not set")
	assert(klavesnice_player is LoopingPlayer, "Klavesnice player not set")
	assert(confirm_player is AudioStreamPlayer, "Confirm player not set")

	visible = false

	dialogue_control.dialogue_advanced.connect(_on_dialogue_advanced)
	text_changed.connect(_on_text_changed)
	player_state.state_changed.connect(_on_player_state_changed)


func _on_dialogue_advanced(_line: String, controls: Dictionary) -> void:
	_on_player_state_updated()


func _on_player_state_changed(new_state: PlayerState.States, old_state: PlayerState.States) -> void:
	_on_player_state_updated()


func _on_player_state_updated():
	visible = player_state.current_state == PlayerState.States.BEING_PROMPTED

	if visible:
		grab_focus()


func _on_text_changed() -> void:
	klavesnice_player.begin(0.5)

	var text_stripped := text.strip_edges()
	if len(text_stripped) <= 0 or text[len(text) - 1] != "\n":
		text = text.replace("\n", "")
		set_caret_column(len(text))
		return

	klavesnice_player.end()
	confirm_player.play()
	# TODO: Private access, meh
	var prompt_name = (
		dialogue_control._current_controls[DialogueControl.Controls.PLAYER_INPUT]["name_attr"]
	)
	player_state.set_prompt(prompt_name, text_stripped)
	text = ""
