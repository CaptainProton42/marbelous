extends SoundShape

var _area : float = 0.0

func set_corners(corners : PoolVector2Array) -> void:
	$Polygon2D.polygon = corners
	$Collision.polygon = corners

	_area = 0.5 * (abs((corners[1] - corners[0]).cross(corners[3] - corners[0]))
				   + abs((corners[1] - corners[2]).cross(corners[3] - corners[2])))
				   
func get_area() -> float:
	return _area

func hit():
	$Polygon2D/AnimationPlayer.play("glow")
