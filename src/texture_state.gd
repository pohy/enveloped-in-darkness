extends Node

var current_idx := 0

signal idx_changed(idx: int)


func advance() -> void:
	current_idx += 1
	idx_changed.emit(current_idx)
