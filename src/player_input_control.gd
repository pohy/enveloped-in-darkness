extends TextEdit

@export var dialogue_control: DialogueControl
@export var player_state: PlayerState

var _player_input_controls: Dictionary = {}


func _ready() -> void:
	assert(dialogue_control is DialogueControl, "DialogueControl not set")
	assert(player_state is PlayerState, "PlayerState not set")

	visible = false

	dialogue_control.dialogue_advanced.connect(_on_dialogue_advanced)
	text_changed.connect(_on_text_changed)


func _on_dialogue_advanced(_line: String, controls: Dictionary) -> void:
	visible = controls.has(DialogueControl.Controls.PLAYER_INPUT)

	if visible:
		grab_focus()
		_player_input_controls = controls[DialogueControl.Controls.PLAYER_INPUT]


func _on_text_changed() -> void:
	var text_stripped := text.strip_edges()
	if len(text_stripped) <= 0 or text[len(text) - 1] != "\n":
		text = text.replace("\n", "")
		set_caret_column(len(text))
		return

	player_state.prompts[_player_input_controls["name_attr"]] = text_stripped

	dialogue_control.advance()
