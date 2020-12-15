extends Node

# Empirical as per paper
const RESAMPLE_FACTOR = 40

func _calculate_bounding_box(polyline: PoolVector2Array) -> Rect2:
	var min_x: float = polyline[0].x
	var max_x: float = polyline[0].x
	var min_y: float = polyline[0].y
	var max_y: float = polyline[0].y

	for pt in polyline:
		max_x = max(pt.x, max_x)
		min_x = min(pt.x, min_x)
		max_y = max(pt.y, max_y)
		min_y = min(pt.y, min_y)

	return Rect2(min_x, min_y, max_x-min_x, max_y-min_y)

func _resample(polyline: PoolVector2Array, pathtimes) -> Array:
	# Resample a freehand polyline with a uniform interspacing distance
	var bb: Rect2 = _calculate_bounding_box(polyline)
	var isd: float = bb.size.length() / RESAMPLE_FACTOR # Interspacing distance

	# Resampling algorithm
	var resampled: PoolVector2Array = [polyline[0]]
	var resampled_times: PoolRealArray = [0.0]
	var d: float = 0.0 # Distance holder
	for i in range(1, polyline.size()):
		var v: Vector2 = polyline[i] - polyline[i-1]
		d += v.length()
		while (d > isd):
			d -= isd
			var pt = polyline[i] - v.normalized() * d
			resampled.append(pt)
			resampled_times.append(resampled_times[resampled_times.size() - 1] + (resampled[resampled.size() - 1] - resampled[resampled.size() - 2]).length())

	return [resampled, resampled_times]

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
	

func _bottom_up(polyline: PoolVector2Array, w: int):
	var corners = [0] # start should be corner
	var straws: PoolRealArray = []
	straws.resize(polyline.size() - 2 * w)

	for i in range(polyline.size() - 2*w):
		straws[i] = (polyline[i+2*w] - polyline[i]).length()

	var median: float = _quickselect_median(straws)
	var thresh: float = 0.95 * median

	for i in range(1, straws.size() - 1):
		if straws[i] < straws[i+1] and straws[i] < straws[i-1] and straws[i] < thresh: # local minimum below threshold
			corners.append(i+w)

	corners.append(polyline.size() - 1) # end should be corner

	return corners

func _check_and_insert(polyline, pathtimes, idx1, idx2, w):
	var distance: float = (polyline[idx2] - polyline[idx1]).length()
	var path_distance: float = (pathtimes[idx2] - pathtimes[idx1])

	if distance / path_distance > 0.95:
		return [idx1]
	else:
		var min_val = 99999999.9 # good start value
		var min_idx = -1
		var quarter = 0.25 * path_distance
		for i in range(max(idx1, w), min(idx2, polyline.size() - 1 - w)):
			var straw = (polyline[i+w] - polyline[i-w]).length()
			if (pathtimes[i] - pathtimes[idx1]) >= quarter and (pathtimes[idx2] - pathtimes[i]) >= quarter:
				if straw < min_val:
					min_val = straw
					min_idx = i

		if min_idx == -1: # fallback for edge cases with begin and end corner
			return [idx1]

		return _check_and_insert(polyline, pathtimes, idx1, min_idx, w) + _check_and_insert(polyline, pathtimes, min_idx, idx2, w)

func _top_down(polyline: PoolVector2Array, pathtimes: PoolRealArray, corner_indices: PoolIntArray, w: int):
	if corner_indices.size() < 3: # Polyline has only start and endpoint
		return corner_indices

	var processed_indices  = []

	for i in range(corner_indices.size() - 1):
		processed_indices += (_check_and_insert(polyline, pathtimes, corner_indices[i], corner_indices[i+1], w))

	processed_indices.append(corner_indices[corner_indices.size() - 1])

	# check colinearity
	var i = 0
	while i < processed_indices.size()-2:
		var d0 = (polyline[processed_indices[i+1]] - polyline[processed_indices[i]]).length()
		var d1 = (polyline[processed_indices[i+2]] - polyline[processed_indices[i+1]]).length()
		var d = (polyline[processed_indices[i+2]] - polyline[processed_indices[i]]).length()

		if (d / (d0 + d1)) > 0.95:
			processed_indices.remove(i+1)
		else:
			i += 1

	return processed_indices

func short_straw(polyline: PoolVector2Array, pathtimes: PoolRealArray) -> PoolVector2Array:
	# ShortStraw algorithm for corner detection. Returns an array with the corner coordinates (excluding start and end points).
	var r = _resample(polyline, pathtimes)
	var resampled = r[0]
	var resampled_times = r[1]
	var corner_indices = _bottom_up(resampled, 3)
	corner_indices = _top_down(resampled, resampled_times, corner_indices, 3)
	var corners: PoolVector2Array = []
	corners.resize(corner_indices.size())
	for i in range(corner_indices.size()):
		corners[i] = resampled[corner_indices[i]]
	return corners
