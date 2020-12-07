extends Node2D
class_name Level

signal level_cleared

var goals : Array = [] #  holds all goals
#var marbles : Array = [] # holds all marbles in the level

var triggered_goals : Array = []

export var invisible_shapes = false

func _ready():
	for c in get_children():
		if c.get_class() == "GoalTrigger":
			goals.append(c)
#		elif c.get_class() == "MarbleSpawner":
#			marbles += c.get_marbles()

#	for m in get_marbles():
#		m.connect("collected", self, "_on_marble_collected", [m])
#		m.connect("entered_state", self, "_on_marble_entered_state", [m])

	for g in goals:
		g.connect("triggered", self, "_on_goal_triggered", [g])
	
	$ShapeSpawner.invisible_shapes = invisible_shapes

func _update_goal_progress_bar(g : Node):
	var max_collected_count = 0
	for m in get_marbles():
		var cur_collected_count = m.get_collected(g.collectible_type)
		max_collected_count = max(cur_collected_count, max_collected_count)
	g.set_max_collectibles(max_collected_count)

func _on_marble_collected(marble : Node):
	for g in goals:
		g.check_marble_for_win_condition(marble)
		_update_goal_progress_bar(g)

func get_marbles():
	return get_tree().get_nodes_in_group("Marbles")

func _on_marble_entered_state(state : int, marble : Node):
	if state == marble.State.DEAD:
		for g in goals:
			g.remove_marble(marble)
			_update_goal_progress_bar(g)

func _on_goal_triggered(goal : Node) -> void:
	triggered_goals.append(goal)
	if triggered_goals.size() == goals.size():
		emit_signal("level_cleared")
