extends Reference
class_name Polydrawing

var _geo = GeometryUtils.new() # Geometry utilities

signal finished # Emitted when the drawing is finished (i.e. finish() is called)
signal updated # Emitted when the drawing is updated (i.e. a new coordinate is appended)
signal array_mesh_updated # Emitted when the array mesh data is updated

var _polyline : PoolVector2Array # coordinates of the polyline
var _pathtimes : PoolRealArray # path times of the polyline
var _active : bool = false
var _is_closed: bool = false # if the last drawn polyline is closed

var _array_mesh : ArrayMesh # An ArrayMesh that is kept up to date with the Polyline
var _mesh_vertices : PoolVector3Array
var _mesh_uvs : PoolVector2Array

var line_width : float = 5.0
var min_distance : float = 5.0
var mesh_uv_scale : float = 100.0

func _append_coordinate(pt: Vector2, t: float):
	_polyline.append(pt)
	_pathtimes.append(t)
	emit_signal("updated")

	# Update the generated mesh
	if _polyline.size() < 2:
		return
	var prev_pt : Vector2 = _polyline[_polyline.size() - 2]
	var dir : Vector2 = pt - prev_pt
	var normal : Vector2 = Vector2(-dir.y, dir.x).normalized()

	_mesh_vertices.push_back(Vector3(pt.x, pt.y, 0.0) + 0.5 * line_width * Vector3(normal.x, normal.y, 0.0))
	_mesh_vertices.push_back(Vector3(pt.x, pt.y, 0.0) - 0.5 * line_width * Vector3(normal.x, normal.y, 0.0))

	_mesh_uvs.append(Vector2(t / line_width / mesh_uv_scale, 1.0))
	_mesh_uvs.append(Vector2(t / line_width / mesh_uv_scale, 0.0))

	var arrays : Array = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[ArrayMesh.ARRAY_VERTEX] = _mesh_vertices
	arrays[ArrayMesh.ARRAY_TEX_UV] = _mesh_uvs

	_array_mesh.surface_remove(0)
	_array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, arrays)
	emit_signal("array_mesh_updated")

func begin(p: Vector2) -> void:
	# Begins a new Polydrawing at the given coordinate. Old polyline data will be deleted.
	if _active:
		push_error("Polydrawing is already active.")
		return
	_polyline = PoolVector2Array()
	_pathtimes = PoolRealArray()
	_array_mesh = ArrayMesh.new()
	_mesh_vertices = PoolVector3Array()
	_mesh_uvs = PoolVector2Array()
	_is_closed = false
	
	_polyline.append(p)
	_pathtimes.append(0.0)
	_active = true

func update(p: Vector2) -> void:
	# Updates the Polydrawing with the given coordinate. Will append the cordinate 
	# if far enough the way and finish the drawing if it was closed.
	if not _active:
		push_error("Polydrawing is not active but was attempted to be updated.")
		return

	var p0 : Vector2 = _polyline[_polyline.size() - 1]
	var t0 : float = _pathtimes[_pathtimes.size() - 1]
	
	var d : float = (p - Vector2(p0.x, p0.y)).length()
	if d > min_distance:
		for i in range(1, _polyline.size() - 1):
			# Check for intersection
			var pa : Vector2 = _polyline[i-1]
			var pb : Vector2 = _polyline[i]

			if _geo.line_segments_intersect(pa, pb, p, Vector2(p0.x, p0.y)):
				# There is an intersection, finish the drawing
				p = _geo.get_line_segment_intersection_point(pa, pb, p, Vector2(p0.x, p0.y))
				d = (p - Vector2(p0.x, p0.y)).length()
				_append_coordinate(p, t0+d)
				# Remove all line segments before the intersection
				for __ in range(i-1):
					_polyline.remove(0)
					_pathtimes.remove(0)
				_polyline[0] = p
				_pathtimes[0] = _pathtimes[1] - (_polyline[1] - _polyline[0]).length()
				_is_closed = true
				finish()
				return
			
		_append_coordinate(p, t0+d)


func finish() -> void:
	# Finish the Polydrawing. Will emit the "finished" sinal.
	if not _active:
		push_error("Polydrawing is not active.")
	_active = false
	emit_signal("finished")

func is_active() -> bool:
	# Returns whether the Polydrawing is active. (That is, begin() has been called 
	# but not finished() yet.)
	return _active

func get_polyline() -> PoolVector2Array:
	# Returns the Polyline.
	return _polyline

func get_pathtimes() -> PoolRealArray:
	# Returns the path times at each coordinate._polyline
	return _pathtimes

func get_array_mesh() -> ArrayMesh:
	return _array_mesh

func is_closed() -> bool:
	return _is_closed