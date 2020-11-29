extends Button

export (PackedScene) var level

signal load_level

func on_pressed():
	emit_signal("load_level", level)
