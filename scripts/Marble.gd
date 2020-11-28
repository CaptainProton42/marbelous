extends RigidBody2D

signal entered_state

enum State {
	ALIVE, 
	DEAD,
	SHOULD_RESET
}

var _state = State.DEAD

func revive() -> void:
	_enter_state(State.SHOULD_RESET)

func kill() -> void:
	_enter_state(State.DEAD)

func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")
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

	_state = p_state
	emit_signal("entered_state", self, _state)
	$Label.text = State.keys()[_state]

func _integrate_forces(state : Physics2DDirectBodyState):

	if state.get_contact_count() > 0:
		var collider = state.get_contact_collider_object(0)
		if collider is StaticBody2D:
			var normal = state.get_contact_local_normal(0)
			var dir = state.linear_velocity.normalized()

			var bounce_dir = dir.reflect(normal)

			print(collider.physics_material_override.bounce)
			# This is terrible. Hopefully noone will notice
			apply_central_impulse(50.0 * (collider.physics_material_override.bounce - 1.0)*bounce_dir)

	state.integrate_forces()

func _on_body_entered(body) -> void:
	if body.get_class() == "SoundShape":
		body.emit_sound()

func _physics_process(_delta : float) -> void:
	if _state == State.SHOULD_RESET:
		linear_velocity = get_parent().start_velocity
		global_transform.origin = get_parent().global_transform.origin
		_enter_state(State.ALIVE)

	if position.y > 500 and _state == State.ALIVE:
		kill()
