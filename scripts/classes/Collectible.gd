extends Area2D
class_name Collectible

export (Array, AudioStream) var collect_sounds

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
	
	if has_node("sound"):
		print("we sound")
		var i = body._collected_nodes.size()-1
		if i < collect_sounds.size():
			$sound.stream = collect_sounds[i]
		else:
			$sound.stream = collect_sounds.back()
		$sound.play()

func get_class() -> String:
	return "Collectible"
