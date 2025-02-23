extends Button

@export var dialogue_control: DialogueControl
@export var player_state: PlayerState

@export_category("Dependencies - Audio")
@export var deny_player: AudioStreamPlayer


func _ready() -> void:
	assert(dialogue_control is DialogueControl, "DialogueControl not set")
	assert(player_state is PlayerState, "PlayerState not set")
	assert(deny_player is AudioStreamPlayer, "Deny player not set")

	visible = false

	dialogue_control.dialogue_advanced.connect(_on_dialogue_advanced)
	player_state.state_changed.connect(_on_player_state_changed)
	pressed.connect(_on_pressed)


func _on_dialogue_advanced(_line: String, controls: Dictionary) -> void:
	visible = (
		player_state.current_state == PlayerState.States.BEING_PROMPTED
		and controls.has(DialogueControl.Controls.CONTINUE)
	)

	if visible:
		text = controls[DialogueControl.Controls.CONTINUE]["text"]


func _on_player_state_changed(new_state: PlayerState.States, old_state: PlayerState.States) -> void:
	visible = new_state == PlayerState.States.BEING_PROMPTED

	if visible:
		grab_focus()


func _on_pressed() -> void:
	dialogue_control.advance_line()
	deny_player.play()
