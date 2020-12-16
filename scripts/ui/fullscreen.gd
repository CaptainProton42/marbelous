extends CheckButton

func _ready():
	pressed = OS.window_fullscreen

func on_pressed():
	OS.window_fullscreen = pressed
