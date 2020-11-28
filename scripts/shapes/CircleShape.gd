extends SoundShape

func set_radius(radius : float) -> void:
	$ScaleTexture.scale = Vector2(radius, radius)
	$Collision.shape.radius = radius
