extends Area2D

signal triggered

func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body) -> void:
	emit_signal("triggered")