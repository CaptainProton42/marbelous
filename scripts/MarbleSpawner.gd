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
export var fixed_timer : float = 4.0 setget set_fixed_timer
export (Sync) var synchronisation
export (float) var marble_lifetime = 0
export (bool) var differentiate_collectibles = true

var _marbles : Array = []
#var _marbles_alive : int = 0
var _spawn_timer : float = 0.0
var _marbles_queued : Array = []
var timer_multiplier := 1.0 setget set_timer_multiplier

var _disabled : bool = false


onready var marble_tscn = preload("res://scenes/Marble.tscn")
onready var sprite_anchor = $SpriteAnchor
onready var sprite = $SpriteAnchor/Sprite

func get_class() -> String:
	return "MarbleSpawner"

func get_marbles() -> Array:
	return _marbles

func _ready():
	# Graphical setup
	if start_velocity.length() > 0.0:
		self.rotation = 0
		sprite_anchor.rotation = start_velocity.angle() - PI/2
	
	$timer.wait_time = fixed_timer
	
	var rate_buttons = get_tree().get_nodes_in_group("rate buttons")
	
	if synchronisation != Sync.TIMER:
		var mat = sprite.get_material()
		mat.set_shader_param("y", 0)
	else:
		var kill_area_anims = get_tree().get_nodes_in_group("kill area animations")
		for k in kill_area_anims:
			var div = k.get_animation(k.current_animation).length / fixed_timer
			if div / int(div) != 1:
				push_warning("A Kill area uses an animation which doesnt have a length multiple of the spawner's rate.")
	
	for rb in rate_buttons:
		rb.visible = synchronisation == Sync.TIMER
	
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
	add_child(marble)
	marble.init(marble_lifetime, differentiate_collectibles)
	
	marble.connect("collected", get_parent(), "_on_marble_collected", [marble])
	marble.connect("collectible_lost", get_parent(), "on_marble_collectible_lost")
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
		var mat = sprite.get_material()
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

func set_fixed_timer(value):
	fixed_timer = value
	$timer.wait_time = fixed_timer * timer_multiplier

func set_timer_multiplier(value):
	value = clamp(value, 0.25, 4)
	timer_multiplier = value
	$timer.wait_time = fixed_timer * timer_multiplier

func on_less_input_event(viewport, event, shape_idx):
	return
	if event.is_action_pressed("ui_accept"):
		set_timer_multiplier(timer_multiplier * 2)

func on_more_input_event(viewport, event, shape_idx):
	return
	if event.is_action_pressed("ui_accept"):
		set_timer_multiplier(timer_multiplier / 2)

func mult_timer_multiplier(m):
	set_timer_multiplier(timer_multiplier * m)

func on_less_mouse_entered():
	return
#	var mat = sprite.get_material()
#	mat.set_shader_param("hover_top", true)

func on_less_mouse_exited():
	return
#	var mat = sprite.get_material()
#	mat.set_shader_param("hover_top", false)

func on_more_mouse_entered():
	return
#	var mat = sprite.get_material()
#	mat.set_shader_param("hover_bottom", true)

func on_more_mouse_exited():
	return
#	var mat = sprite.get_material()
#	mat.set_shader_param("hover_bottom", false)
