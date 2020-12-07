# TODO: Maybe move respawning of the marble to a separate node

extends Node2D

enum Sync { 
	MARBLE_DEATH, 
#	MARBLE_DEATH_COUPLED,
	TIMER
}

export var max_marbles_alive : int = 1
export var start_velocity : Vector2 = Vector2(0.0, 0.0)
export var min_time_between_spawns : float = 5.0
export var fixed_timer : float = 4.0
export (Sync) var synchronisation

var _marbles : Array = []
#var _marbles_alive : int = 0
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
	
	$timer.wait_time = fixed_timer
	
	if synchronisation != Sync.TIMER:
		var mat = $SpriteAnchor/Sprite.get_material()
		mat.set_shader_param("y", 0)
	
	_spawn_marble()

func _on_marble_entered_state(state : int, marble) -> void:
	match state:
		marble.State.DEAD:
			# Respawn the marble instantly
			_spawn_marble()
			
		marble.State.IN_GOAL:
			disable()

func _spawn_marble() -> void:
	if _disabled:
		return
	
	var marble = marble_tscn.instance()
#	marble.connect("entered_state", self, "_on_marble_entered_state", [marble])
	_marbles.append(marble)
	marble.init()
	add_child(marble)
	
	marble.connect("collected", get_parent(), "_on_marble_collected", [marble])
	marble.connect("entered_state", get_parent(), "_on_marble_entered_state", [marble])

	$AnimationPlayer.play("spawn")
	_spawn_timer = min_time_between_spawns
	$timer.start()

func _process(delta : float) -> void:
	if not _disabled:
		match synchronisation:
			Sync.TIMER:
				if _spawn_timer <= 0.0:
					_spawn_marble()
			
			Sync.MARBLE_DEATH:
				if get_marbles_alive() < max_marbles_alive:
					_spawn_marble()
			
		_spawn_timer -= delta
	
	if synchronisation == Sync.TIMER:
		var mat = $SpriteAnchor/Sprite.get_material()
		mat.set_shader_param("y", 1 - $timer.time_left / $timer.wait_time)

func disable():
	_disabled = true

func get_marbles_alive():
	var sum = 0
	for c in get_children():
		if c.is_in_group("Marbles"):
			sum += 1
	return sum

func _on_timer_timeout():
	if synchronisation == Sync.TIMER:
		_spawn_marble()
