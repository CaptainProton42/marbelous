extends SoundShape

var _area : float = 0.0

func set_radius(radius : float) -> void:
	$ScaleTexture.scale = Vector2(radius, radius)
	$Collision.shape.radius = radius
	_area = PI * radius * radius

func get_area() -> float:
	return _area
