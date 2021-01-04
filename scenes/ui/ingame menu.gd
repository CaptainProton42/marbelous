extends Node2D

signal go_to_main
signal restart

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		close()

func on_main_pressed():
	emit_signal("go_to_main")

func on_restart_pressed():
	emit_signal("restart")
	close()

func on_return_pressed():
	close()

func close():
	queue_free()

