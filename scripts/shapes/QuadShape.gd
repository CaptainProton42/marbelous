extends SoundShape

var _area : float = 0.0

func set_corners(corners : PoolVector2Array) -> void:
	position = (corners[0] + corners[1] + corners[2] + corners[3]) / 4.0

	var polygon : PoolVector2Array = []
	polygon.resize(4)
	for i in range(4):
		polygon[i] = corners[i] - position
	$Polygon2D.polygon = polygon
	$Collision.polygon = polygon

	_area = 0.5 * (abs((corners[1] - corners[0]).cross(corners[3] - corners[0]))
				   + abs((corners[1] - corners[2]).cross(corners[3] - corners[2])))
	
	if _area == 0:
		printerr("Quad shape with area of 0 => deleting")
		queue_free()
	

func get_area() -> float:
	return _area

func play_animation():
	$Polygon2D/AnimationPlayer.play("hit")

func _process(_delta):
	$Polygon2D.position = last_hit_normal * hit_displacement_amp

func _ready():
	$Polygon2D/AnimationPlayer.stop()
	$Polygon2D/AnimationPlayer.play("create")

func set_invisible(invisible):
	$Polygon2D/AnimationPlayer.get_animation("create").track_set_enabled(1, invisible)
	$Polygon2D/AnimationPlayer.get_animation("hit").track_set_enabled(3, invisible)

func remove():
	if not can_remove():
		return
	
	emit_signal("removed")
	$Polygon2D/AnimationPlayer.play("remove")
	yield($Polygon2D/AnimationPlayer, "animation_finished")
	queue_free()

func destroy():
	# TODO: "Destruction" animation
	$Polygon2D/AnimationPlayer.play("remove")
	yield($Polygon2D/AnimationPlayer, "animation_finished")
	queue_free()