class_name PlayerState
extends Node

# TODO: Dunno
enum PlayerPrompt { MEMORY }
var prompts := {}

# var is_being_prompted := false

@export var dialogue_control: DialogueControl

# func _ready() -> void:
# 	assert(dialogue_control is DialogueControl, "DialogueControl not set")

# 	dialogue_control.dialogue_advanced.connect(_on_dialogue_advanced)

# func _on_dialogue_advanced(_line: String, controls: Dictionary) -> void:
# 	is_being_prompted = controls.size() > 0
