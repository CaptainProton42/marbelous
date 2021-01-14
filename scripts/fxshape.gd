extends Area2D

export var random_shape = true

func _enter_tree():
	if random_shape:
		randomize()
		var p = generate_polygon()
		print(p)
		$polygon.polygon = p
		$collision.polygon = p
		
func generate_polygon()->PoolVector2Array:
	var a = []
	var N = int(rand_range(5, 10))
	var w = ProjectSettings.get_setting("display/window/size/width")
	var h = ProjectSettings.get_setting("display/window/size/height")
	var s = 2
	
	for i in range(N):
		var p = Vector2(randi()%w, randi()%h)
		a.append(p)
	
	a = Geometry.convex_hull_2d(a)
	a = Geometry.offset_polygon_2d(a, -s)[0]
	
	return a
	
