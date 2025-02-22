class_name Player
extends CharacterBody3D

@export_category("Movement")
@export var speed := 5.0
@export var speed_sprint := 10.0

@export_category("Dependencies")
@export var ray_cast: RayCast3D
@export var mouse: MouseInpt
@export var mouse_manager: MouseManager
@export var player_state: PlayerState
@export var dialogue_control: DialogueControl
@export var interaction_icon: Sprite2D

@export_category("Dependencies - Audio")

var _current_interactive: Interactive = null


func _ready() -> void:
	assert(ray_cast is RayCast3D, "RayCast3D not set")
	assert(mouse is MouseInpt, "Mouse not set")
	assert(mouse_manager is MouseManager, "MouseManager not set")
	assert(player_state is PlayerState, "PlayerState not set")
	assert(dialogue_control is DialogueControl, "DialogueControl not set")
	assert(interaction_icon is Sprite2D, "Interaction icon not set")


func _process(_delta: float) -> void:
	interaction_icon.visible = (
		player_state.current_state == PlayerState.States.INTERACTING
		and _current_interactive != null
	)
	mouse_manager.is_hidden = player_state.current_state != PlayerState.States.BEING_PROMPTED

	if player_state.current_state == PlayerState.States.BEING_PROMPTED:
		return

	if mouse.delta.length_squared() > 0:
		_on_mouse_motion()


func _physics_process(delta: float) -> void:
	if player_state.current_state == PlayerState.States.BEING_PROMPTED:
		return

	_process_movement(delta)


func _input(event: InputEvent) -> void:
	if event is InputEvent and event.is_action_pressed("action_primary"):
		match player_state.current_state:
			PlayerState.States.INTERACTING:
				if _current_interactive:
					_current_interactive.interact()
			PlayerState.States.IN_DIALOGUE:
				dialogue_control.advance()


func _on_mouse_motion() -> void:
	var collider = ray_cast.get_collider()
	# TODO: Choose collision layer based on state (placing vs. interacting)
	var collision_layer_ := 2
	if not collider or not collider.get_collision_layer_value(collision_layer_):
		_current_interactive = null
		return

	_current_interactive = collider


func _process_movement(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	# if Input.is_action_just_pressed("jump") and is_on_floor():
	# 	velocity.y = jump_velocity

	var speed_current := speed_sprint if Input.is_action_pressed("sprint") else speed

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction.length_squared() > 0:
		velocity.x = direction.x * speed_current
		velocity.z = direction.z * speed_current
	else:
		velocity.x = move_toward(velocity.x, 0, speed_current)
		velocity.z = move_toward(velocity.z, 0, speed_current)

	move_and_slide()
