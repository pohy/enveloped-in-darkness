class_name PlayerState
extends Node

enum States { INTERACTING, IN_DIALOGUE, BEING_PROMPTED, PLACING_PROMPT }

signal state_changed(new_state: PlayerState.States, old_state: PlayerState.States)

var prompts := {}
var current_state: States = States.INTERACTING:
	set(value):
		var last_state = current_state
		if last_state != value:
			current_state = value
			print("Player state changed: %s -> %s" % [last_state, current_state])
			state_changed.emit(current_state, last_state)


func set_prompt(prompt: String, value: String) -> void:
	prompts[prompt] = value


func set_state(state: States) -> void:
	current_state = state


func set_state_interacting() -> void:
	set_state(States.INTERACTING)


func set_state_in_dialogue() -> void:
	set_state(States.IN_DIALOGUE)


func set_state_being_prompted() -> void:
	set_state(States.BEING_PROMPTED)


func set_state_placing_prompt() -> void:
	set_state(States.PLACING_PROMPT)


func on_interacted(interactive_name: Interactive.Name) -> void:
	match interactive_name:
		Interactive.Name.DOOR:
			set_state(States.IN_DIALOGUE)
		_:
			set_state(States.INTERACTING)
