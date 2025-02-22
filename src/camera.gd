extends Camera3D

@export var mouse: MouseInpt
@export var mouse_manager: MouseManager


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(mouse is MouseInpt, "Mouse not set")
	assert(mouse_manager is MouseManager, "MouseManager not set")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not mouse_manager.is_hidden:
		return

	var rot_delta_y := -mouse.delta.y * delta
	rotate(basis.x.normalized(), rot_delta_y)

	if rotation_degrees.x > 90 or rotation_degrees.x < -90:
		rotate(basis.x.normalized(), -rot_delta_y)

	get_parent().rotate(Vector3.UP, -mouse.delta.x * delta)
