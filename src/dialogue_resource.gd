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
	# Filter out empty lines
	for i in range(lines.size()):
		if lines[i].strip_edges() == "":
			lines.remove_at(i)

	if lines.size() == 0:
		printerr("No lines in file: " + file_path)

	file.close()


func get_player_input_from_line(line: String):
	var player_input_tag := "player_input"
	var name_attr = "name"

	var start_partial := "[%s %s=" % [player_input_tag, name_attr]
	var start = line.find(start_partial)
	if start == -1:
		return {}
	var start_closing := line.find("]")
	if start_closing == -1:
		printerr("Mising closing bracket for player_input in line:\n%s" % line)
		return null

	var end_partial := "[/%s]" % player_input_tag
	var end = line.find(end_partial)
	if end == -1:
		printerr("Mising closing tag for player_input in line:\n%s" % line)
		return null

	var input_name := line.substr(
		start + len(start_partial), start_closing - start - len(start_partial)
	)

	var match := line.substr(start, end + len(end_partial) - start)

	return {"name_attr": input_name, "stripped": line.replace(match, "")}


func get_continue_from_line(line: String):
	var continue_tag := "continue"

	var start_partial := "[%s]" % continue_tag
	var start = line.find(start_partial)
	if start == -1:
		return null

	var end_partial := "[/%s]" % continue_tag
	var end = line.find(end_partial)
	if end == -1:
		printerr("Mising closing tag for continue in line:\n%s" % line)
		return null

	var continue_text := line.substr(start + len(start_partial), end - start - len(start_partial))

	var match := line.substr(start, end + len(end_partial) - start)

	return {"text": continue_text, "stripped": line.replace(match, "")}
