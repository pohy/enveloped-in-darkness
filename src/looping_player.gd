class_name LoopingPlayer
extends AudioStreamPlayer

var _should_loop = false


func _ready() -> void:
	finished.connect(_on_finished)


func begin(duration_s := -1.0) -> void:
	_should_loop = true
	play()

	print("LoopingPlayer(%s): Playing for %s seconds" % [name, duration_s])

	if duration_s > 0:
		await create_tween().tween_interval(duration_s).finished
		end()


func end() -> void:
	_should_loop = false
	stop()

	print("LoopingPlayer(%s): Stopped" % name)


func _on_finished() -> void:
	if _should_loop:
		play()
