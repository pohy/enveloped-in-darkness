class_name Interactive
extends CollisionObject3D

enum Name {
	DOOR,
}

signal interacted(name: Interactive.Name)

@export var interactive_name: Interactive.Name = Interactive.Name.DOOR
@export var is_enabled := true


func interact() -> void:
	if not is_enabled:
		return

	interacted.emit(interactive_name)
	print("Interacted with %s (%s)" % [name, interactive_name])


func disable() -> void:
	is_enabled = false


func enable() -> void:
	is_enabled = true
