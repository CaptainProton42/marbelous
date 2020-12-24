extends Node2D

signal go_to_main
signal next_level

func on_main_pressed():
	emit_signal("go_to_main")

func on_next_pressed():
	emit_signal("next_level")
