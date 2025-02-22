class_name DialogueResource
extends Resource

@export_file("*.txt") var file_path: String

var text: String = ""
var lines: PackedStringArray = []


func load() -> void:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		printerr("Could not open file: " + file_path)
		return

	text = file.get_as_text()
	lines = text.split("\n")

	if lines.size() == 0:
		printerr("No lines in file: " + file_path)

	file.close()
