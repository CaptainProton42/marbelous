extends StaticBody2D

func set_polygon(poly: PoolVector2Array) -> void:
	$VerletChain2D.polygon = poly

func set_tautness(tautness: float) -> void:
	$VerletChain2D.tautness = tautness

func _ready():
	$VerletChain2D.connect("updated", self, "_on_chain_updated")

func _on_chain_updated():
	var vertices = $VerletChain2D.get_vertices()
	var collision_polygon: PoolVector2Array = PoolVector2Array()
	collision_polygon.resize(vertices.size() * 2)
	for i in range(vertices.size()):
		var pt = vertices[i]
		var dir
		if i == 0:
			dir = vertices[i+1] - pt
		else:
			dir = pt - vertices[i-1]
		var normal = Vector2(-dir.y, dir.x).normalized()

		collision_polygon[i] = vertices[i] + 3.0 * normal
		collision_polygon[collision_polygon.size()-1-i] = vertices[i] - 3.0 * normal
	$CollisionPolygon2D.polygon = collision_polygon
