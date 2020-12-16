extends Node

# Algorithm parameters
# Standard values are taken from the paper and shouldn't be modified unless you know what you're doing.
var resample_factor: int = 40
var straw_length: int = 3 # half length, actually
var straw_threshold: float = 0.95
var line_threshold: float = 0.95

# Run the algorithm
func run(points: PoolVector2Array) -> PoolVector2Array:
	var s: float = _determine_resample_spacing(points)
	var resampled: PoolVector2Array = _resample_points(points, s)
	var corners: PoolIntArray = _get_corners(resampled)
	var corner_points: PoolVector2Array = _get_corner_points(resampled, corners)
	return corner_points

# Runs in O(n) on average, O(n^2) in worst case
func _quickselect(arr, k):
	if arr.size() == 1:
		return arr[0]

	var pivot = arr[randi() % arr.size()]

	var lows : Array = []
	var highs : Array = []
	var pivots : Array = [] # We can have multiple entries with the pivot value

	for i in range(arr.size()):
		var val = arr[i]
		if val < pivot:
			lows.append(val)
		elif val > pivot:
			highs.append(val)
		else:
			pivots.append(val)

	if k < lows.size():
		return _quickselect(lows, k)
	elif k < lows.size() + pivots.size():
		return pivot
	else:
		return _quickselect(highs, k - lows.size() - pivots.size())

func _quickselect_median(arr):
	if arr.size() % 2 == 0:
		return _quickselect(arr, arr.size() / 2)
	else:
		return 0.5 * (_quickselect(arr, (arr.size() - 1) / 2)
					  + _quickselect(arr, (arr.size() + 1) / 2))

func _calculate_bounding_box(points: PoolVector2Array) -> Rect2:
	var min_x: float = points[0].x
	var max_x: float = points[0].x
	var min_y: float = points[0].y
	var max_y: float = points[0].y

	for pt in points:
		max_x = max(pt.x, max_x)
		min_x = min(pt.x, min_x)
		max_y = max(pt.y, max_y)
		min_y = min(pt.y, min_y)

	return Rect2(min_x, min_y, max_x-min_x, max_y-min_y)

func _get_corner_points(points: PoolVector2Array, corners: PoolIntArray) -> PoolVector2Array:
	var corner_points: PoolVector2Array = []
	corner_points.resize(corners.size())
	for i in range(corners.size()):
		corner_points[i] = points[corners[i]]
	return corner_points

func _determine_resample_spacing(points: PoolVector2Array) -> float:
	var bb: Rect2 = _calculate_bounding_box(points)
	var s: float = bb.size.length() / resample_factor
	return s

func _resample_points(points: PoolVector2Array, s: float) -> PoolVector2Array:
	# Resampling algorithm
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

func _get_corners(points: PoolVector2Array):
	var corners = [0] # start should be corner

	# Calculate the straws
	var straws: PoolRealArray = []
	straws.resize(points.size() - 2 * straw_length)
	for i in range(points.size() - 2 * straw_length):
		straws[i] = (points[i+2*straw_length] - points[i]).length()

	var t: float = _quickselect_median(straws) * straw_threshold

	var i = 0
	while i < straws.size():
		if straws[i] < t:
			var local_min: float = straws[i]
			var local_min_index: float = i
			while i < straws.size() and straws[i] < t:
				if straws[i] < local_min:
					local_min = straws[i]
					local_min_index = i
				i += 1
			corners.append(local_min_index + straw_length)
		i += 1

	corners.append(points.size() - 1) # end should be corner

	corners = _post_process_corners(points, corners, straws)

	return corners

func _post_process_corners(points: PoolVector2Array, corners: PoolIntArray, straws: PoolRealArray) -> PoolIntArray:
	if corners.size() < 3: # Polyline has only start and endpoint
		return corners

	var i: int = 1
	while i < corners.size():
		var c1: int = corners[i - 1]
		var c2: int = corners[i]
		if not _is_line(points, c1, c2):
			var new_corner: int = _halfway_corner(straws, c1, c2)
			corners.insert(i, new_corner)
			i -= 1
		i += 1

	i = 1
	while i < corners.size() - 1:
		var c1: int = corners[i-1]
		var c2: int = corners[i+1]

		if _is_line(points, c1, c2):
			corners.remove(i)
		else:
			i += 1

	return corners

func _halfway_corner(straws: PoolRealArray, a: int, b: int) -> int:
	var quarter: int = int(floor((b - a) / 2.0))
	var min_value: float = straws[a + quarter]
	var min_index: int = a + quarter
	for i in range(a + quarter, b - quarter):
		if straws[i] < min_value:
			min_value = straws[i]
			min_index = i

	return min_index

func _is_line(points: PoolVector2Array, a: int, b: int) -> bool:
	var distance: float = _distance(points, a, b)
	var path_distance: float = _path_distance(points, a, b)

	if distance / path_distance > line_threshold:
		return true
	else:
		return false

func _distance(points: PoolVector2Array, a: int, b: int) -> float:
	return (points[b] - points[a]).length()

func _path_distance(points: PoolVector2Array, a: int, b: int) -> float:
	var d: float = 0.0
	for i in range(a, b-1):
		d += _distance(points, i, i+1)

	return d
