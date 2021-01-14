extends Area2D

onready var circle_shape_tscn = preload("res://scenes/shapes/CircleShape.tscn")
onready var triangle_shape_tscn = preload("res://scenes/shapes/TriangleShape.tscn")
onready var quad_shape_tscn = preload("res://scenes/shapes/QuadShape.tscn")
onready var string_shape_tscn = preload("res://scenes/shapes/StringShape.tscn")

var _geo = GeometryUtils.new()

var _polydrawing = Polydrawing.new()
var _shortstraw = ShortStraw.new()

export var invisible_shapes: bool = false
export var removable_shapes: bool = true
export var string_shape_allowed = false

func _resample_points(points: PoolVector2Array, s: float) -> PoolVector2Array:
	var resampled: PoolVector2Array = [points[0]]

	var d: float = 0.0 # Distance holder
	for i in range(1, points.size()):
		var v: Vector2 = points[i] - points[i-1]
		d += v.length()
		while (d > s):
			d -= s
			var pt = points[i] - v.normalized() * d
			resampled.append(pt)

	return resampled
	

# Total curvature of an open polyline
func _turning_number(corners: PoolVector2Array) -> float:
	var t: float = 0.0
	var last_segment: Vector2 = corners[1] - corners[0]
	for i in range(2, corners.size()):
		var new_segment: Vector2 = corners[i] - corners[i-1]
		t += last_segment.angle_to(new_segment)
		last_segment = new_segment

	return t / 2.0 / PI

func _ready() -> void:
	connect("input_event", self, "_on_input_event")
	connect("mouse_exited", self, "_on_mouse_exited")
	_polydrawing.connect("finished", self, "_on_polydrawing_finished")
	_polydrawing.connect("updated", self, "_on_polydrawing_updated")
	_polydrawing.connect("array_mesh_updated", self, "_on_polydrawing_array_mesh_updated")

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			_polydrawing.begin(get_local_mouse_position())
			$MeshInstance2D.visible = true
			$MeshInstance2D.mesh = _polydrawing.get_array_mesh()
		else:
			if _polydrawing.is_active():
				_polydrawing.finish()
	elif event is InputEventMouseMotion:
		if _polydrawing.is_active():
			_polydrawing.update(get_local_mouse_position())

func _on_mouse_exited() -> void:
	if _polydrawing.is_active():
		_polydrawing.finish()

func _on_polydrawing_finished() -> void:
	var polyline: PoolVector2Array = _polydrawing.get_polyline()
	var pathtime: PoolRealArray = _polydrawing.get_pathtimes()
	var closed: bool = _polydrawing.is_closed()

	if polyline.size() < 2:
		return

	var corners: PoolVector2Array = _shortstraw.run(polyline)

	if closed:
		corners.remove(corners.size() - 1)
	else:
		var new_corners: PoolVector2Array = _close_shape(corners)
		if new_corners != corners:
			closed = true
			corners = new_corners

	if closed:
		if corners.size() == 3:
			var triangle_shape = triangle_shape_tscn.instance()
			triangle_shape.set_corners(corners)
			triangle_shape.set_invisible(invisible_shapes)
			triangle_shape.removable = removable_shapes
			$ShapeAnchor.add_child(triangle_shape)
		elif corners.size() == 4:
			var quad_shape = quad_shape_tscn.instance()
			quad_shape.set_corners(corners)
			quad_shape.set_invisible(invisible_shapes)
			quad_shape.removable = removable_shapes
			$ShapeAnchor.add_child(quad_shape)
		else:
			var circle_shape = circle_shape_tscn.instance()
			var circum: float = pathtime[pathtime.size() - 1] - pathtime[0]
			var area = _geo.get_polygon_area(polyline)
			if abs(1.0 - 4.0 * PI * area / circum / circum) < 0.2:
				circle_shape.set_radius(sqrt(area / PI))
				circle_shape.position = _geo.get_polygon_center(polyline)
				circle_shape.set_invisible(invisible_shapes)
				circle_shape.removable = removable_shapes
				$ShapeAnchor.add_child(circle_shape)
	elif string_shape_allowed:
		if abs(_turning_number(corners)) < 0.5:
			var length = pathtime[pathtime.size() - 1] - pathtime[0]
			var dist = (corners[corners.size() - 1] - corners[0]).length()
			var tautness = dist / length
			var stringpoly = _resample_points(polyline, length / 15.0)
			var string = string_shape_tscn.instance()
			string.set_polygon(stringpoly)
			string.set_tautness(tautness)
			$ShapeAnchor.add_child(string)
	
	$MeshInstance2D.visible = false
	$MeshInstance2D.mesh = null

func _close_shape(corners: PoolVector2Array) -> PoolVector2Array:
	if corners.size() < 3:
		return corners
	var v1: Vector2 = (corners[1] - corners[0]).normalized()
	var v2: Vector2 = (corners[corners.size() - 1] - corners[corners.size() - 2]).normalized()

	var turns: float = abs(_turning_number(corners))
	
	if abs(turns - 1.0) < 0.1:
		if (corners[1] - corners[corners.size() - 2]).normalized().dot(v1) < 0.95:
			return corners

		# Do close by removing first and last point.
		corners.remove(corners.size() - 1)
		corners.remove(0)
	elif abs(turns) > 0.5:
		var a1: Vector2 = corners[1]
		var b1: Vector2 = corners[corners.size() - 2]
		var a2: Vector2 = corners[0] - 200.0 * v1
		var b2: Vector2 = corners[corners.size() - 1] + 200.0 * v2

		if _geo.line_segments_intersect(a1, a2, b1, b2):
			corners.remove(corners.size() - 1)
			corners[0] = _geo.get_line_segment_intersection_point(a1, a2, b1, b2)

	return corners
			
func _on_polydrawing_updated() -> void:
	pass

func _on_polydrawing_array_mesh_updated() -> void:
	pass

func clear_shapes() -> void:
	for c in $ShapeAnchor.get_children():
		c.destroy()
