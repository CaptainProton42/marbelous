extends Node2D

func _ready():
	var i = AudioServer.bus_count
	AudioServer.add_bus(i)
	AudioServer.set_bus_name(i, "bibi")
	AudioServer.set_bus_send(i, "shape")
	$audio.bus = "bibi"

func _on_disto_pressed():
#	$audio.bus = "distortion"
	var i = AudioServer.get_bus_index("bibi")
	AudioServer.set_bus_send(i, "distortion")

func _on_shapes_pressed():
#	$audio.bus = "bibi"
	var i = AudioServer.get_bus_index("bibi")
	AudioServer.set_bus_send(i, "shape")
