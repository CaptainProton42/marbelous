extends BaseShape

func set_radius(radius : float) -> void:
	$ScaleTexture.scale = Vector2(radius, radius)
	$CollisionShape2D.shape.radius = radius
