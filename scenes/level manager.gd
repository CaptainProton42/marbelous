extends Node2D

export (PackedScene) var main_menu_scene
export (PackedScene) var win_menu_scene
export (PackedScene) var ingame_menu_scene

var loaded_level
var current_level_i = 0
var main_menu
var win_menu
var ingame_menu

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
	if ingame_menu:
		ingame_menu.close()

func go_to_main_menu():
	main_menu = main_menu_scene.instance()
	add_child(main_menu)
	main_menu.connect("load_level", self, "load_level")
	clear_level()

func go_to_win_menu():
	if ingame_menu:
		ingame_menu.close()
	
	win_menu = win_menu_scene.instance()
	add_child(win_menu)
	win_menu.connect("go_to_main", self, "go_to_main_menu")
	win_menu.connect("next_level", self, "load_next_level")

func toggle_ingame_menu():
	if not ingame_menu:
		go_to_ingame_menu()
	else:
		ingame_menu.close()

func go_to_ingame_menu():
	if ingame_menu:
		ingame_menu.close()
	
	ingame_menu = ingame_menu_scene.instance()
	add_child(ingame_menu)
	ingame_menu.connect("go_to_main", self, "go_to_main_menu")
	ingame_menu.connect("restart", loaded_level, "restart")

func load_level(level):
	clear_ui()
	clear_level()
	
	loaded_level = level.instance()
	loaded_level.connect("level_cleared", self, "on_level_cleared")
	add_child(loaded_level)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if win_menu == null and loaded_level != null:
			toggle_ingame_menu()

func on_level_cleared():
	on_level_complete()

func on_level_complete():
	go_to_win_menu()
