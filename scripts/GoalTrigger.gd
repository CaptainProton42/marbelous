extends Area2D

export(Collectible.Type) var collectible_type = Collectible.Type.NOTE
export var collectibles_needed : int = 1

enum State {
	CLOSED,
	OPEN,
	TRIGGERED
}

var _state : int = State.CLOSED

var _marbles_with_win_condition : Array = []

signal triggered
signal entered_state

func get_class() -> String:
	return "GoalTrigger"

func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body) -> void:
	if _state == State.OPEN:
		if body in _marbles_with_win_condition:
			_enter_state(State.TRIGGERED)

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

	_state = new_state
	emit_signal("entered_state", _state)

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
			_enter_state(State.CLOSED)