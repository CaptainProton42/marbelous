extends Node2D

export (PackedScene) var level

signal load_level

func on_pressed():
	emit_signal("load_level", level)


func on_shape_input_event(viewport, event, shape_idx):
	print(event)
