extends VSlider

func _ready():
	value = db2linear(AudioServer.get_bus_volume_db(0))

func set_volume(ratio): #ratio [0; 1]
	AudioServer.set_bus_volume_db(0, linear2db(ratio))

func on_volume_value_changed(value):
	set_volume(ratio)
