tool
extends Area2D

export var copy_polygon = false

func _process(delta):
	if Engine.editor_hint and copy_polygon:
		$collision.polygon = $fill.polygon
		copy_polygon = false

func _on_decay_area_body_entered(body):
	print("body entered")
