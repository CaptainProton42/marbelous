extends Node2D

func _on_ShapeSpawner_shape_created(shape):
	for decay_area in get_tree().get_nodes_in_group("Decay areas"):
		if decay_area.overlaps_body(shape):
			$label.text = "shape is in decay area"
		else:
			$label.text = "i don't see it"

func _on_fxshape_body_entered(body):
	AudioServer.set_bus_effect_enabled(1, 2, true)

func _on_fxshape_body_exited(body):
	AudioServer.set_bus_effect_enabled(1, 2, false)
