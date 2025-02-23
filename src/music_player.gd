extends AudioStreamPlayer

enum Tracks { AMBIENCE, PHASE_0, PHASE_1, PHASE_2, PHASE_FINAL, CACOPHONY }

var track_current: Tracks = Tracks.AMBIENCE

var _playback: AudioStreamPlaybackInteractive


func _ready() -> void:
	_playback = get_stream_playback()
	assert(_playback is AudioStreamPlaybackInteractive, "Playback is not interactive")

	switch_track(Tracks.AMBIENCE)


func switch_track(track: Tracks) -> void:
	print("Switching track %s -> %s" % [track_current, track])

	track_current = track
	_playback.switch_to_clip(track_current)


func advance_track() -> void:
	switch_track(mini(track_current + 1, Tracks.CACOPHONY))


func switch_to_ambience() -> void:
	switch_track(Tracks.AMBIENCE)


func switch_to_phase_0() -> void:
	switch_track(Tracks.PHASE_0)


func switch_to_phase_1() -> void:
	switch_track(Tracks.PHASE_1)


func switch_to_phase_2() -> void:
	switch_track(Tracks.PHASE_2)


func switch_to_phase_final() -> void:
	switch_track(Tracks.PHASE_FINAL)


func switch_to_cacophony() -> void:
	switch_track(Tracks.CACOPHONY)
