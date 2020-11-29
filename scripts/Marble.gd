extends RigidBody2D

signal entered_state

enum State {
	ALIVE, 
	DEAD,
	SHOULD_RESET
}

var _state = State.DEAD
var _collected : PoolIntArray = [] # Counts how many collectibles are picked up (per type)
var _collected_nodes : Array = [] # We need to keep track of which collectibles have aleady been picked up

func revive() -> void:
	_enter_state(State.SHOULD_RESET)

func kill() -> void:
	_enter_state(State.DEAD)
	if has_node("death"):
		$death.play()

func _ready() -> void:
	_collected.resize(Collectible.Type.size())
	for i in range(_collected.size()):
		_collected[i] = 0

	_enter_state(_state)

func _enter_state(p_state : int) -> void:
	match p_state:
		State.DEAD:
			visible = false
			$CollisionShape2D.disabled = true
			
		State.SHOULD_RESET:
			set_sleeping(false)
			visible = true
			$CollisionShape2D.disabled = false
			_collected = []
			_collected_nodes = []

	_state = p_state
	emit_signal("entered_state", self, _state)
	$Label.text = State.keys()[_state]

func _integrate_forces(state : Physics2DDirectBodyState):

	if state.get_contact_count() > 0:
		var collider = state.get_contact_collider_object(0)
		if collider.get_class() == "SoundShape":
			# Bounce and trigger sound
			var normal = state.get_contact_local_normal(0)
			var dir = state.linear_velocity.normalized()
			
			var bounce_dir = dir.reflect(normal)

			collider.emit_sound()
			collider.hit(normal)
			
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

func get_collected(type : int) -> int:
	return _collected[type]