extends Node2D

func _ready():
	get_node("../ShapeSpawner").connect("shape_created", self, "_on_shape_created")

func _on_shape_created(shape):
	if ($Center.global_position - shape.global_position).length() <= 200:
		shape.connect("removed", self, "_on_shape_removed")
		$HowToDraw.visible = false
		$HowToRemove.visible = true

func _on_shape_removed():
	$HowToDraw.visible = true
	$HowToRemove.visible = false