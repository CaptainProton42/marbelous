extends StaticBody2D
class_name SoundShape

export var audio_stream : AudioStream

var pitch_quantization = true
var semitones = [-12, -9, -7, -5, -2, 1, 3, 5, 7, 10, 12]
var steps = []

func get_area() -> float:
	return 0.0

func get_class() -> String:
	return "SoundShape"

func semi_to_pitch(semitones):
	return pow(2, semitones/12.0)

func _ready():
	$AudioStreamPlayer.stream = audio_stream
	for s in semitones:
		steps.append(semi_to_pitch(s))

func emit_sound(pitch : float = 1.0):
	var area = get_area()
	
	if area > 0:
		var pitch_scaling = 0.0001
		var continuous_pitch = area * pitch_scaling
		var discrete_pitch = quantize_pitch(continuous_pitch)
		$AudioStreamPlayer.pitch_scale = 1/discrete_pitch
#		printt(area, discrete_pitch)
	
#	$AudioStreamPlayer.pitch_scale = pitch
	$AudioStreamPlayer.play()


func quantize_pitch(pitch):
	if not pitch_quantization:
		return pitch
	
	var minimum_delta = 99
	var candidate
	for s in steps:
		if abs(pitch-s) < minimum_delta:
			minimum_delta = abs(pitch-s)
			candidate = s
	return candidate
