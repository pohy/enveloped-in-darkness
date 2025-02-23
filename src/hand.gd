class_name Hand
extends TextureRect

enum States { OPEN, IDLE, GRAB }

@export var texture_open: Texture
@export var texture_idle: Texture
@export var texture_grab: Texture

var current_state: States = States.IDLE


func _ready() -> void:
	assert(texture_open is Texture, "Texture Open must be a Texture")
	assert(texture_idle is Texture, "Texture Idle must be a Texture")
	assert(texture_grab is Texture, "Texture Grab must be a Texture")

	set_state(States.IDLE)
	_update_texture()


func set_state(state: States) -> void:
	if state != current_state:
		current_state = state
		_update_texture()


func _update_texture() -> void:
	match current_state:
		States.OPEN:
			texture = texture_open
		States.IDLE:
			texture = texture_idle
		States.GRAB:
			texture = texture_grab

	pivot_offset = texture.get_size()
