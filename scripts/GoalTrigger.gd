extends Area2D

export(Collectible.Type) var collectible_type = Collectible.Type.NOTE
export var collectibles_needed : int = 1

onready var collectible_progress_indicator_tscn = preload("res://scenes/CollectibleProgressIndicator.tscn")

enum State {
	CLOSED,
	OPEN,
	TRIGGERED
}

var _state : int = State.CLOSED
var _max_collectibles : int = 0 # max number of collectibles already collected by a marble
var _marbles_with_win_condition : Array = []

signal triggered
signal entered_state

func get_class() -> String:
	return "GoalTrigger"

func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")
	
	if collectibles_needed == 0:
		_enter_state(State.OPEN)
	else:
		# Initialize progress bar
		for i in range(collectibles_needed):
			var indicator = collectible_progress_indicator_tscn.instance()
			indicator.set_fill(false)
			indicator.position.x = 20 * i - 0.5 * 20 * (collectibles_needed - 1)
			$Progress.add_child(indicator)

func _on_body_entered(body) -> void:
	if _state == State.OPEN:
		if body.is_in_group("Marbles"):
			body.reach_goal()
			_enter_state(State.TRIGGERED)
#		if body in _marbles_with_win_condition:
#			body.reach_goal()
#			_enter_state(State.TRIGGERED)
		else:
			$fail.play()

func on_marble_death():
	if collectibles_needed == 0:
		return
	else:
		_enter_state(State.CLOSED)

func _enter_state(new_state : int) -> void:
	match new_state:
		State.CLOSED:
			$AnimationPlayer.play_backwards("open")
		State.OPEN:
			$AnimationPlayer.play("open")
		State.TRIGGERED:
			$AnimationTree.active = false
			$AnimationPlayer.play("trigger")
			emit_signal("triggered")
			$success.play()

	_state = new_state
	emit_signal("entered_state", _state)

func set_max_collectibles(count : int) -> void:
	if count > collectibles_needed:
		count = collectibles_needed
	
	if count > _max_collectibles:
		for i in range(_max_collectibles, count):
			$Progress.get_child(i).set_fill(true)
	else:
		for i in range(count, _max_collectibles):
			$Progress.get_child(i).set_fill(false)
	_max_collectibles = count

func check_marble_for_win_condition(marble : Node) -> void:
	if _state == State.CLOSED:
		if marble.get_collected(collectible_type) == collectibles_needed:
			if not marble in _marbles_with_win_condition:
				_marbles_with_win_condition.append(marble)
				
		if _marbles_with_win_condition.size() > 0:
			_enter_state(State.OPEN)

func remove_marble(marble : Node) -> void:
	if _state == State.OPEN:
		_marbles_with_win_condition.erase(marble)
		
		if _marbles_with_win_condition.size() == 0:
			on_marble_death()
