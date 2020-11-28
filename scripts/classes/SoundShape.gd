extends StaticBody2D
class_name SoundShape

export var audio_stream : AudioStream

func get_area() -> float:
	return 0.0

func get_class() -> String:
	return "SoundShape"

func semi_to_pitch(semitones):
	return pow(2, semitones/12)

func _ready():
	$AudioStreamPlayer.stream = audio_stream

func emit_sound(pitch : float = 1.0):
	var area = get_area()
	var label = Label.new()
	add_child(label)
	label.rect_global_position = position
	label.text = String(area)
	
	if area > 0:
		var pitch_scaling = 0.02
		var discrete_pitch = area * pitch_scaling
		var semitones = [1, 3, 5, 7, 10]
		var pitches = []
		for s in semitones:
			pitches.append(semi_to_pitch(s))
		$AudioStreamPlayer.pitch_scale = discrete_pitch
	
#	$AudioStreamPlayer.pitch_scale = pitch
	$AudioStreamPlayer.play()
