extends StaticBody2D
class_name SoundShape

signal removed

export var audio_stream : AudioStream
export var hit_displacement_amp : float = 0.0 # Displace the shape slightly when hit

var last_hit_normal : Vector2 = Vector2(0.0, 0.0)

var pitch_quantization = true
var semitones = [-12, -9, -7, -5, -2, 1, 3, 5, 7, 10, 12]
var steps = []
var pitch_scaling = 0.0001
var removable = true

func get_area() -> float:
	return 0.0

func get_class() -> String:
	return "SoundShape"

func semi_to_pitch(semitones):
	return pow(2, semitones/12.0)

func _ready():
	connect("input_event", self, "_on_input_event")
	$AudioStreamPlayer2D.stream = audio_stream
	for s in semitones:
		steps.append(semi_to_pitch(s))

func hit(n : Vector2, velocity = 0.0, marble_bus_name = "") -> void:
	last_hit_normal = n
	emit_sound(velocity, marble_bus_name)
	play_animation()

func play_animation():
	pass

func emit_sound(velocity = 0.0, marble_bus_name = ""):
	var area = get_area()
	
	var volume = sqrt(velocity / 1000)
	volume = clamp(volume, 0.0, 1.0)
	volume = linear2db(volume)
	
	if area > 0:
		var continuous_pitch = area * pitch_scaling
		var discrete_pitch = quantize_pitch(continuous_pitch)
		$AudioStreamPlayer2D.pitch_scale = 1/discrete_pitch
	else:
		printerr("Shape area is 0")
	
	var clone = $AudioStreamPlayer2D.duplicate()
	add_child(clone)
	clone.volume_db = volume
	clone.bus = marble_bus_name
	clone.connect("finished", clone, "queue_free")
	clone.play()
	
	return clone


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

func release():
	var tween = Tween.new()
	add_child(tween)
	$AudioStreamPlayer2D.volume_db
	tween.interpolate_property(
		$AudioStreamPlayer2D, "volume_db", 
		$AudioStreamPlayer2D.volume_db, -80, 1.0, 
		Tween.TRANS_CIRC)
	tween.start()

func can_remove():
	return removable

func remove():
	pass

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.is_pressed():
			remove()
