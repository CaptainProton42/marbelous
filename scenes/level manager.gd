extends Node2D

export (PackedScene) var main_menu_scene
export (PackedScene) var win_menu_scene

var loaded_level
var current_level_i = 0
var main_menu
var win_menu

func _ready():
	go_to_main_menu()

func load_next_level():
	var level = get_next_level()
	load_level(level)

func get_next_level():
	current_level_i += 1
	var level = LevelList.get_level(LevelList.get_level_name(current_level_i))
	return level

func clear_level():
	if loaded_level:
		loaded_level.queue_free()

func clear_ui():
	if main_menu:
		main_menu.queue_free()
	if win_menu:
		win_menu.queue_free()

func go_to_main_menu():
	main_menu = main_menu_scene.instance()
	add_child(main_menu)
	main_menu.connect("load_level", self, "load_level")
	clear_level()

func go_to_win_menu():
	win_menu = win_menu_scene.instance()
	add_child(win_menu)
	win_menu.connect("go_to_main", self, "go_to_main_menu")
	win_menu.connect("next_level", self, "load_next_level")

func load_level(level):
	clear_ui()
	clear_level()
	
	loaded_level = level.instance()
	loaded_level.connect("level_cleared", self, "on_level_cleared")
	add_child(loaded_level)

func _input(event):
	if event is InputEventKey and event.is_pressed() and event.scancode == KEY_ESCAPE:
		clear_level()
		go_to_main_menu()

func on_level_cleared():
	on_level_complete()

func on_level_complete():
	go_to_win_menu()
