extends Node2D

var loaded_level
var current_level_i = 0

func _ready():
	for l in $levels.get_children():
		l.connect("load_level", self, "load_level")

func load_next_level():
	var level = get_next_level()
	load_level(level)

func get_next_level():
	current_level_i += 1
	var level = get_level(current_level_i)
	return level

func get_level(i):
	if i < 0 or i >= LevelList.list.size():
		printerr("Attempting to get a level out of level list range")
		return null
	
	var level_name = LevelList.list[i]
	
	var file = File.new()
	var path = "res://scenes/levels/" + level_name + ".tscn"
	
	if file.file_exists(path):
		var scene = load(path)
		return scene
	else:
		printerr("level scene not found at: ", path)
		return null

func clear_level():
	if loaded_level:
		loaded_level.queue_free()

func go_to_main_menu():
	$win.hide()
	clear_level()

func load_level(level):
	$win.hide()
	clear_level()
	loaded_level = level.instance()
	loaded_level.connect("level_cleared", self, "on_level_cleared")
	add_child(loaded_level)

func _input(event):
	if event is InputEventKey and event.is_pressed() and event.scancode == KEY_ESCAPE:
		clear_level()

func on_level_cleared():
	on_level_complete()

func on_level_complete():
	move_child($win, get_child_count())
	$win.show()
