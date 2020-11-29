# TODO: Maybe move respawning of the marble to a separate node

extends Node2D

export var max_marbles_alive : int = 1
export var start_velocity : Vector2 = Vector2(0.0, 0.0)
export var min_time_between_spawns : float = 5.0

var _marbles : Array = []
var _marbles_alive : int = 0
var _spawn_timer : float = 0.0
var _marbles_queued : Array = []

var _disabled : bool = false


onready var marble_tscn = preload("res://scenes/Marble.tscn")

func get_class() -> String:
	return "MarbleSpawner"

func get_marbles() -> Array:
	return _marbles

func _ready():
	# Graphical setup
	if start_velocity.length() > 0.0:
		$SpriteAnchor.rotation = start_velocity.angle_to(Vector2(0.0, -1.0))
	for _i in range(max_marbles_alive):
		var marble = marble_tscn.instance()
		marble.connect("entered_state", self, "_on_marble_entered_state", [marble])
		_marbles.append(marble)
		add_child(marble)

func _on_marble_entered_state(state : int, marble) -> void:
	match state:
		marble.State.DEAD:
			# Respawn the marble instantly
			_marbles_alive -= 1
			_spawn_marble(marble)
		marble.State.IN_GOAL:
			disable()

func _spawn_marble(marble) -> void:
	# Try to spawn the marble. If too early, put it in queue
	if not _disabled:
		if _spawn_timer <= 0.0:
			$AnimationPlayer.play("spawn")
			marble.revive()
			_spawn_timer = min_time_between_spawns
			_marbles_alive += 1
		else:
			_marbles_queued.push_back(marble)

func _process(delta : float) -> void:
	if not _disabled:
		if _spawn_timer <= 0.0 and _marbles_queued.size() > 0:
			_spawn_marble(_marbles_queued.back())
			_marbles_queued.pop_back()
			
		_spawn_timer -= delta

func disable():
	_disabled = true
