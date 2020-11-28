extends Area2D

signal picked_up

func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body) -> void:
	$AnimationPlayer.play("pickup")
	emit_signal("picked_up")
	yield($AnimationPlayer, "animation_finished")
	queue_free()