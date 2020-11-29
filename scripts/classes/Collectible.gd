extends Area2D
class_name Collectible

signal picked_up

enum Type {
	NOTE
}

export(Type) var type : int = Type.NOTE

func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body) -> void:
	body.collect(self)
	$AnimationPlayer.play("pickup")
	emit_signal("picked_up")

func get_class() -> String:
	return "Collectible"