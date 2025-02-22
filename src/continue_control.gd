extends Button

@export var dialogue_control: DialogueControl


func _ready() -> void:
	assert(dialogue_control is DialogueControl, "DialogueControl not set")

	visible = false

	dialogue_control.dialogue_advanced.connect(_on_dialogue_advanced)
	pressed.connect(_on_pressed)


func _on_dialogue_advanced(_line: String, controls: Dictionary) -> void:
	visible = controls.has(DialogueControl.Controls.CONTINUE)

	if visible:
		text = controls[DialogueControl.Controls.CONTINUE]["text"]


func _on_pressed() -> void:
	dialogue_control.advance()
