extends SoundShape

var _area : float = 0.0

func set_radius(radius : float) -> void:
	$Texture/Scale.scale = Vector2(radius, radius)
	$Collision.shape = $Collision.shape.duplicate()
	$Collision.shape.radius = radius

	_area = PI * radius * radius

func get_area() -> float:
	return _area

func play_animation():
	$Texture/AnimationPlayer.stop()
	$Texture/AnimationPlayer.play("hit")

func _process(_delta):
	$Texture.position = last_hit_normal * hit_displacement_amp

func _ready():
	$Texture/AnimationPlayer.play("create")

func remove():
	$Texture/AnimationPlayer.play("remove")
	yield($Texture/AnimationPlayer, "animation_finished")
	queue_free()
