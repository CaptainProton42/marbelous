extends Area2D
class_name Collectible

export (Array, AudioStream) var collect_sounds
## if ownership_time > 0, the collectible is lost ownership_time seconds after having been grabbed
export (float) var ownership_time
## if persistent, the collectible will stay in place even after having been grabbed
export (bool) var persistent

signal picked_up

var ownership_timer

enum Type {
	NOTE
}

export(Type) var type : int = Type.NOTE

func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")
	if ownership_time > 0:
		ownership_timer = Timer.new()
		add_child(ownership_timer)
		ownership_timer.wait_time = ownership_time

func disable():
	$AnimationPlayer.play("pickup")
	$Collision.disabled = true
	yield($AnimationPlayer, "animation_finished")
	visible = false
	monitoring = false

func enable():
	$AnimationPlayer.play("respawn")
	visible = true
	$Collision.disabled = false
	monitoring = true

func _on_body_entered(body) -> void:
	body.collect(self)
	emit_signal("picked_up")
	if ownership_timer:	# Start ownership countdown, at the end of which the collectible is lost
		ownership_timer.connect("timeout", body, "on_collectible_ownership_timeout", [self])
		ownership_timer.connect("timeout", self, "on_ownership_timeout")
		ownership_timer.start()
	
	if has_node("sound"):
		var i = body._collected_nodes.size()-1
		if i < collect_sounds.size():
			$sound.stream = collect_sounds[i]
		else:
			$sound.stream = collect_sounds.back()
		$sound.play()
	
	if not persistent:
		disable()

func get_class() -> String:
	return "Collectible"

func on_ownership_timeout():
	enable()
