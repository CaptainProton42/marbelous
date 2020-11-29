extends Node2D

var loaded_level

func _ready():
	for l in $levels.get_children():
		l.connect("load_level", self, "load_level")

func clear_level():
	if loaded_level:
		loaded_level.queue_free()

func load_level(level):
	clear_level()
	loaded_level = level.instance()
	add_child(loaded_level)
	
func _input(event):
	if event is InputEventKey and event.is_pressed() and event.scancode == KEY_ESCAPE:
		clear_level()
