extends Node2D

signal shape_created

var invisible_shapes = false

onready var drawing = get_node("LineDrawing2D")
onready var shape_anchor = get_node("ShapeAnchor")

onready var circle_shape_tscn = preload("res://scenes/shapes/CircleShape.tscn")
onready var triangle_shape_tscn = preload("res://scenes/shapes/TriangleShape.tscn")
onready var quad_shape_tscn = preload("res://scenes/shapes/QuadShape.tscn")

func _ready() -> void:
	drawing.connect("circle_created", self, "_on_circle_created")
	drawing.connect("triangle_created", self, "_on_triangle_created")
	drawing.connect("quad_created", self, "_on_quad_created")

func add_shape(shape):
	shape_anchor.add_child(shape)
	shape.set_invisible(invisible_shapes)
	
	for decay_area in get_tree().get_nodes_in_group("Decay areas"):
		if decay_area.overlaps_body(shape):
			print("shape is in decay area")
		else:
			print("shape is NOT in decay area")
		
		printt(decay_area, decay_area.get_overlapping_bodies())

func _on_circle_created(position : Vector2, radius : float) -> void:
	var circle_shape = circle_shape_tscn.instance()
	circle_shape.set_radius(radius)
	circle_shape.position = position
	add_shape(circle_shape)

	emit_signal("shape_created", circle_shape)

func _on_triangle_created(corners : PoolVector2Array) -> void:
	var triangle_shape = triangle_shape_tscn.instance()
	triangle_shape.set_corners(corners)
	add_shape(triangle_shape)

	emit_signal("shape_created", triangle_shape)

func _on_quad_created(corners : PoolVector2Array) -> void:
	var quad_shape = quad_shape_tscn.instance()
	quad_shape.set_corners(corners)
	add_shape(quad_shape)

	emit_signal("shape_created", quad_shape)

func clear_shapes():
	for s in shape_anchor.get_children():
		if s.has_method("remove"):
			s.remove()
		else:
			s.queue_free()
