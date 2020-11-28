extends StaticBody2D
class_name SoundShape

export var audio_stream : AudioStream

func get_area() -> float:
    return 0.0

func get_class() -> String:
    return "SoundShape"

func _ready():
    $AudioStreamPlayer.stream = audio_stream

func emit_sound(pitch : float = 1.0):
    $AudioStreamPlayer.pitch_scale = pitch
    $AudioStreamPlayer.play()