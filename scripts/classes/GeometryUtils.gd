extends Reference
class_name GeometryUtils

# Utility class for some computational geometry functions.

static func get_line_segment_intersection_point(p1 : Vector2, p2 : Vector2, p3 : Vector2, p4 : Vector2) -> Vector2:
	# Get intersection point of the two line segments p1-p2 and p3-p4.
	# Will return the intersection point of both lines containing the segments, even if the segments do
	# not intersect. If neccessary, check for intersection with GeomtryUtils.line_segments_intersect first.
	var denom : float = (p1.x - p2.x) * (p3.y - p4.y) - (p1.y - p2.y) * (p3.x - p4.x)
	var t : float =  ((p1.x - p3.x) * (p3.y - p4.y) - (p1.y - p3.y) * (p3.x - p4.x)) / denom

	return Vector2(p1.x + t*(p2.x - p1.x), p1.y + t*(p2.y - p1.y))

static func line_segments_intersect(p1 : Vector2, p2 : Vector2, p3 : Vector2, p4 : Vector2) -> bool:
	# Checks if the two line segments p1-p2 and p3-p4 intersect.
	if not (max(p1.x, p2.x) >= min(p3.x, p4.x) and max(p3.x, p4.x) >= min(p1.x, p2.x) and max(p1.y, p2.y) >= min(p3.y, p4.y) and max(p3.y, p4.y) >= min(p1.y, p2.y)):
		return false
	
	if ((p3 - p1).cross(p2 - p1)) * ((p4 - p1).cross(p2 - p1)) < 0.0 and ((p1 - p3).cross(p4 - p3)) * ((p2 - p3).cross(p4 - p3)) < 0.0:
		return true
	else:
		return false

static func get_polygon_area(poly: PoolVector2Array) -> float:
	# Calculates the signed area of an arbitrary, non self-intersecting polygon.
	var r: float = 0.0
	var n: int = poly.size()
	for i in range(n):
		r += poly[(i+1)%n].x * (poly[(i+2)%n].y - poly[i].y)
	return 0.5 * abs(r)

static func get_polygon_center(poly: PoolVector2Array) -> Vector2:
	var r: Vector2 = Vector2(0.0, 0.0)
	var n: int = poly.size()
	for i in range(n):
		r += poly[i]
	return r / n