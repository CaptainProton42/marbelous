extends Node

const list = [
	"nothing",
	"sidestep",
	"bump in the road",
	"launch",
	"horseshoe",
	"straight lock",
	"side key",
	"the one",
	"messy",
	"lozenge",
	"thrice",
	"non delete",
	"wipers",
	"loki"
#
#	"Level verybasic",
#	"Level0",
#	"Level 2sides 1note wwait",
#	"Level1",
#	"Level invisible shapes",
#	"1 marble",
#	"marble lifetime",
#	"decay pass"
]

func get_level(level_name):
	var file = File.new()
	var path = "res://scenes/levels/" + level_name + ".tscn"
	
	if file.file_exists(path):
		var scene = load(path)
		return scene
	else:
		printerr("level scene not found at: ", path)
		return null

func get_level_name(i):
	if i < 0 or i >= LevelList.list.size():
		printerr("Attempting to get a level out of level list range")
		return null
	
	var level_name = LevelList.list[i]
	return level_name
