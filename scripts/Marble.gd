extends RigidBody2D

class_name Marble

export (PackedScene) var death_particles

signal entered_state
signal collected

enum State {
	ALIVE, 
	DEAD,
	SHOULD_RESET,
	IN_GOAL
}

var _state = State.DEAD
var _collected : PoolIntArray = [] # Counts how many collectibles are picked up (per type)
var _collected_nodes : Array = [] # We need to keep track of which collectibles have aleady been picked up
var lifetime = 5.0

func init(l = 0.0):
	lifetime = l
	if lifetime > 0:
		$sentence.wait_time = lifetime
		$sentence.start()
	_enter_state(State.SHOULD_RESET)
	
	create_bus()

func create_bus():
	var i = AudioServer.bus_count
	AudioServer.add_bus(i)
	AudioServer.set_bus_name(i, get_bus_name())
	route_bus()

func route_bus(bus_name = "shape"):
	var i = AudioServer.get_bus_index(get_bus_name())
	AudioServer.set_bus_send(i, bus_name)

func revive() -> void:
	_enter_state(State.SHOULD_RESET)

func kill() -> void:
	_enter_state(State.DEAD)
	if has_node("death"):
		$death.play()
	
	# particles are instanced and dropped in parent
	var particles = death_particles.instance()
	get_parent().add_child(particles)
	particles.global_position = self.global_position
	particles.emitting = true

func _reset_collectibles() -> void:
	_collected.resize(Collectible.Type.size())
	for i in range(_collected.size()):
		_collected[i] = 0
	_collected_nodes = []

func _ready() -> void:
	_reset_collectibles()

	_enter_state(_state)

func _enter_state(p_state : int) -> void:
	match p_state:
		State.DEAD:
#			visible = false
			$Sprite.visible = false	# So the particles can be visible despite marble death
#			$CollisionShape2D.disabled = true
			set_sleeping(true)
			for c in _collected_nodes:
				c.enable()

			_reset_collectibles()
			
			if not $death.is_connected("finished", self, "queue_free"):
				$death.connect("finished", self, "queue_free")
#			queue_free()
			
			
		State.SHOULD_RESET:
			set_sleeping(false)
#			visible = true
			$Sprite.visible = true
			$CollisionShape2D.disabled = false

		State.IN_GOAL:
			if _state != State.IN_GOAL:
				$AnimationPlayer.play("in_goal")
				set_sleeping(true)
				$CollisionShape2D.disabled = true
				yield($AnimationPlayer, "animation_finished")
				visible = false

	_state = p_state
	emit_signal("entered_state", _state)
	$Label.text = State.keys()[_state]

func _integrate_forces(state : Physics2DDirectBodyState):

	if state.get_contact_count() > 0:
		var collider = state.get_contact_collider_object(0)
		if collider.get_class() == "SoundShape":
			# Bounce and trigger sound
			var normal = state.get_contact_local_normal(0)
			var dir = state.linear_velocity.normalized()
			
			var bounce_dir = dir.reflect(normal)

			collider.hit(normal, state.linear_velocity.length(), get_bus_name())
			
			# This is terrible. Hopefully noone will notice
			apply_central_impulse(50.0 * (collider.physics_material_override.bounce - 1.0)*bounce_dir)

	state.integrate_forces()

func sigmoid(x : float) -> float:
	return x / (1 + abs(x))

func _physics_process(_delta : float) -> void:
	if _state == State.SHOULD_RESET:
		linear_velocity = get_parent().start_velocity
		global_transform.origin = get_parent().global_transform.origin
		_enter_state(State.ALIVE)

	#var offset = -20.0*linear_velocity.normalized() * sigmoid(linear_velocity.length())

	#$Sprite/marble_eye.offset = offset
	#$Sprite/marble_eye2.offset = offset
	#$Sprite/marble_mouth.offset = offset

func collect(collectible : Node):
	if not collectible in _collected_nodes:
		_collected_nodes.append(collectible)
		_collected[collectible.type] += 1
	emit_signal("collected")

func get_collected(type : int) -> int:
	return _collected[type]

func reach_goal():
	_enter_state(State.IN_GOAL)

func on_sentence_timeout():
	if lifetime > 0:
		kill()

func get_bus_name():
	return self.to_string()
