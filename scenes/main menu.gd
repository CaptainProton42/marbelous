extends Node2D

export (PackedScene) var level_button

onready var levels_ui = $ui/main/levels
onready var win_ui = $ui/win
onready var options_ui = $"ui/options menu"

signal load_level

func _ready():
	for l in LevelList.list:
		var instance = level_button.instance()
		levels_ui.add_child(instance)
		instance.connect("load_level", self, "load_level")
		instance.text = l
		var level = LevelList.get_level(l)
		instance.level = level

func load_level(level):
	emit_signal("load_level", level)

func on_options_pressed():
	options_ui.show()

func on_options_close_pressed():
	options_ui.hide()

func on_quit_pressed():
	get_tree().quit()
