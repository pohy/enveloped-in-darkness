class_name MouseManager
extends Node

var _is_hidden: bool = false

var can_hide: bool = true
@export var is_hidden: bool:
	get:
		return _is_hidden
	set(value):
		_toggle(value)


func _ready() -> void:
	_toggle(_is_hidden)


# func _input(event: InputEvent) -> void:
# 	# TODO: We want to disable auto hiding when the player is being prompted
# 	if (
# 		not _is_hidden
# 		and event is InputEventMouseButton
# 		and event.pressed
# 		and event.button_index == MOUSE_BUTTON_LEFT
# 	):
# 		_toggle(true)
# 	if event.is_action_pressed("ui_cancel"):
# 		if _is_hidden:
# 			_toggle(false)
# 		# else:
# 		# 	# TODO: Coupling :D
# 		# 	get_tree().quit()


func _toggle(value: bool) -> void:
	_is_hidden = value
	if _is_hidden:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
