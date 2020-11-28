extends Resource
class_name Drawing

signal shape_completed
signal shape_failed

var _points : PoolVector2Array = []
var _mesh : MeshInstance2D = MeshInstance2D.new()
var _polyline : PoolVector2Array = []
var _collision_polygon : CollisionPolygon2D = CollisionPolygon2D.new()
var _texture_size : Vector2
var _line_width : float
var _line_color : Color
var _vertices : PoolVector3Array = []

var _corner_detected : bool = false
var _corners : PoolVector2Array = []

# Parameters for corner detection
var corner_detection_distance : float = 75.0
var corner_detection_angle : float = 0.3 * PI

# Parameters for intersection detection
var isec_detection_grace_dist : float = 20.0

# Parameters for closing shapes
var close_shape_distance : float = 150.0

func line_segments_intersect(p1 : Vector2, p2 : Vector2, p3 : Vector2, p4 : Vector2) -> bool:
	if not (max(p1.x, p2.x) >= min(p3.x, p4.x) and max(p3.x, p4.x) >= min(p1.x, p2.x) and max(p1.y, p2.y) >= min(p3.y, p4.y) and max(p3.y, p4.y) >= min(p1.y, p2.y)):
		return false
	
	if ((p3 - p1).cross(p2 - p1)) * ((p4 - p1).cross(p2 - p1)) < 0.0 and ((p1 - p3).cross(p4 - p3)) * ((p2 - p3).cross(p4 - p3)) < 0.0:
		return true
	else:
		return false

func get_line_segment_intersection_point(p1 : Vector2, p2 : Vector2, p3 : Vector2, p4 : Vector2) -> Vector2:
	# Stolen from Wikipedia
	var denom : float = (p1.x - p2.x) * (p3.y - p4.y) - (p1.y - p2.y) * (p3.x - p4.x)
	var t : float =  ((p1.x - p3.x) * (p3.y - p4.y) - (p1.y - p3.y) * (p3.x - p4.x)) / denom

	return Vector2(p1.x + t*(p2.x - p1.x), p1.y + t*(p2.y - p1.y))

func get_area(start_index : int = 0) -> float:
	var area : float = 0.0
	for i in range(start_index, _points.size()):
		var j = (i + 1) % _points.size()
		area += _points[i].cross(_points[j])

	return 0.5 * abs(area)

func get_circumference(start_index : int = 0) -> float:
	var cf : float = 0.0
	for i in range(start_index + 1, _points.size()):
		cf += (_points[i] - _points[i - 1]).length()
	return cf

func get_com(start_index : int = 0) -> Vector2:
	var com : Vector2 = Vector2(0.0, 0.0)
	for i in range(start_index, _points.size()):
		com += _points[i]
	return com / (_points.size() - start_index)

func get_corners() -> PoolVector2Array:
	return _corners

func append_point(pt : Vector2):
	_points.append(pt)
	_generate_mesh()

	if (_points.size() > 1):
		var prev_pt : Vector2 = _points[_points.size() - 2]
			
		# Vertices
		var dir : Vector2 = pt - prev_pt
		var normal : Vector2 = Vector2(-dir.y, dir.x).normalized()
			
		_vertices.push_back(Vector3(pt.x, pt.y, 0.0) + 0.5 * _line_width * Vector3(normal.x, normal.y, 0.0))
		_vertices.push_back(Vector3(pt.x, pt.y, 0.0) - 0.5 * _line_width * Vector3(normal.x, normal.y, 0.0))

		_check_for_intersection()

		# Rolling sum of last few angles
		var angle_sum : float = 0.0
		var back_distance : float = 0.0
		var i = _points.size() - 1
		while back_distance < corner_detection_distance:
			if (i < 3):
				return
			angle_sum += (_points[i-1] - _points[i-2]).angle_to((_points[i] - _points[i-1]))
			back_distance += (_points[i] - _points[i - 1]).length()
			i -= 1
		angle_sum = abs(angle_sum)
		if (angle_sum >= corner_detection_angle and not _corner_detected):
			_corner_detected = true
			_corners.append(_points[_points.size() - 1])
		elif (_corner_detected and angle_sum < corner_detection_angle):
			_corner_detected = false

func _close_shape():
	# Just close with the beginnig
	if (_points.size() < 2):
		emit_signal("shape_failed")
	elif (_points[_points.size() - 1] - _points[0]).length() < close_shape_distance:
		_points.append(_points[0])
		emit_signal("shape_completed", 0)
	else:
		emit_signal("shape_failed")


func _check_for_intersection():
	var dist : float = 0.0
	var j : int = _points.size() - 1

	# Exclude segments within grace distance
	while dist < isec_detection_grace_dist:
		if (j < _points.size() - 3):
			return
		dist += (_points[j] - _points[j - 1]).length()
		j -= 1

	for i in range(1, j):
		if line_segments_intersect(_points[i-1], _points[i], _points[_points.size() - 2], _points[_points.size() - 1]):
			_points[_points.size() - 1] = get_line_segment_intersection_point(_points[i-1], _points[i], _points[_points.size() - 2], _points[_points.size() - 1])
			emit_signal("shape_completed", i)

func _generate_mesh():
	if _points.size() < 2:
		return

	var arr_mesh = ArrayMesh.new()
	var arrays : Array = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[ArrayMesh.ARRAY_VERTEX] = _vertices
	#arrays[ArrayMesh.ARRAY_TEX_UV] = uvs

	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, arrays)
	_mesh.mesh = arr_mesh
	_mesh.self_modulate = _line_color


func get_mesh() -> MeshInstance2D:
	return _mesh

func get_points() -> PoolVector2Array:
	return _points

func get_collision_polygon() -> CollisionPolygon2D:
	return _collision_polygon
