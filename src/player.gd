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
@export var hold_point: Node3D
@export var rich_text_label_3d_scene: PackedScene
@export var hand: Hand

@export_category("Dependencies - Audio")
@export var kroky_player: LoopingPlayer
@export var place_player: AudioStreamPlayer
@export var interact_player: AudioStreamPlayer

var _current_interactive: Interactive = null
var _current_prompt_label: RichTextLabel3D = null


func _ready() -> void:
	assert(ray_cast is RayCast3D, "RayCast3D not set")
	assert(mouse is MouseInpt, "Mouse not set")
	assert(mouse_manager is MouseManager, "MouseManager not set")
	assert(player_state is PlayerState, "PlayerState not set")
	assert(dialogue_control is DialogueControl, "DialogueControl not set")
	assert(rich_text_label_3d_scene is PackedScene, "RichTextLabel 3D scene not set")
	assert(hold_point is Node3D, "Hold point not set")
	assert(hand is Hand, "Hand not set")
	assert(kroky_player is LoopingPlayer, "Kroky player not set")
	assert(place_player is AudioStreamPlayer, "Place player not set")
	assert(interact_player is AudioStreamPlayer, "Interact player not set")

	player_state.state_changed.connect(_on_player_state_changed)


func _process(_delta: float) -> void:
	mouse_manager.is_hidden = player_state.current_state != PlayerState.States.BEING_PROMPTED
	_update_hand()

	if player_state.current_state == PlayerState.States.BEING_PROMPTED:
		return

	if mouse.delta.length_squared() > 0:
		_on_mouse_motion()

	if player_state.current_state == PlayerState.States.PLACING_PROMPT:
		_update_prompt_position()


func _physics_process(delta: float) -> void:
	if player_state.current_state == PlayerState.States.BEING_PROMPTED:
		return

	_process_movement(delta)


func _input(event: InputEvent) -> void:
	if event is InputEvent and event.is_action_pressed("action_primary"):
		match player_state.current_state:
			PlayerState.States.INTERACTING:
				if _current_interactive:
					hand.set_state(Hand.States.GRAB)
					var interactive := _current_interactive
					interact_player.play()
					await create_tween().tween_interval(0.2).finished
					interactive.interact()
			PlayerState.States.IN_DIALOGUE:
				dialogue_control.advance_line()
			PlayerState.States.PLACING_PROMPT:
				if _current_prompt_label:
					hand.set_state(Hand.States.OPEN)
					place_player.play()
					await create_tween().tween_interval(0.2).finished
					_current_prompt_label.reparent(get_tree().root)
					dialogue_control.advance_line()  # Will change PlayerState as a side-effect


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

	if direction.length_squared() > 0 and is_on_floor():
		if not kroky_player.playing:
			kroky_player.begin()
	else:
		if kroky_player.playing:
			kroky_player.end()

	move_and_slide()


func _start_placing_prompt():
	_current_prompt_label = rich_text_label_3d_scene.instantiate()
	_current_prompt_label.scale = Vector3.ONE * 3
	_current_prompt_label.text = player_state.prompts[player_state.current_prompt]
	_current_prompt_label.rotate_x(deg_to_rad(90))
	hold_point.add_child(_current_prompt_label)


func _update_prompt_position():
	if not ray_cast.is_colliding():
		_current_prompt_label.position = Vector3.ZERO
		_current_prompt_label.rotation_degrees = Vector3.ZERO
		_current_prompt_label.rotate_x(deg_to_rad(90))
		return

	var hit_position = ray_cast.get_collision_point()
	var hit_normal = ray_cast.get_collision_normal()
	_current_prompt_label.global_position = hit_position + hit_normal * 0.1


func _update_hand():
	match player_state.current_state:
		PlayerState.States.INTERACTING:
			hand.visible = true

			if hand.current_state == Hand.States.GRAB:
				return

			hand.set_state(
				(
					Hand.States.IDLE
					if _current_interactive == null or not _current_interactive.is_enabled
					else Hand.States.OPEN
				)
			)
		PlayerState.States.PLACING_PROMPT:
			hand.visible = true

			if hand.current_state == Hand.States.OPEN:
				return
			hand.set_state(Hand.States.GRAB)
		_:
			hand.visible = false


func _on_player_state_changed(new_state: PlayerState.States, old_state: PlayerState.States) -> void:
	match new_state:
		PlayerState.States.PLACING_PROMPT:
			_start_placing_prompt()
		PlayerState.States.INTERACTING:
			hand.set_state(Hand.States.OPEN)
		PlayerState.States.PLACING_PROMPT:
			hand.set_state(Hand.States.GRAB)
