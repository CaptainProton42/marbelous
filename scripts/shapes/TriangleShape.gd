extends BaseShape

onready var polygon = get_node("Polygon2D")
onready var collision_polygon = get_node("CollisionPolygon2D")

func set_corners(corners : PoolVector2Array) -> void:
	$Polygon2D.polygon = corners
	$CollisionPolygon2D.polygon = corners
