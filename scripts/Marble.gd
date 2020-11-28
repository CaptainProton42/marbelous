extends RigidBody2D

signal entered_state

enum State {
	ALIVE, 
	DEAD
}

var _state = State.DEAD

func revive() -> void:
	_enter_state(State.ALIVE)

func _ready() -> void:
	_enter_state(_state)

func _enter_state(p_state : int) -> void:
	match p_state:
		State.DEAD:
			visible = false
			$CollisionShape2D.disabled = true
		State.ALIVE:
			visible = true
			$CollisionShape2D.disabled = false

	_state = p_state
	emit_signal("entered_state", self, _state)

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
