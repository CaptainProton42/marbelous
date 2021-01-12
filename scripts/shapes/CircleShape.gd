extends SoundShape

export (float) var radius setget set_radius

var _area : float = 0.0
var decaying = false

func set_radius(r : float) -> void:
	radius = r
	
	$Texture/Scale.scale = Vector2(radius, radius)
	$Collision.shape = $Collision.shape.duplicate()
	$Collision.shape.radius = radius
	
	if radius == 0:
		printerr("Circle shape with radius of 0 => deleting")
		queue_free()
	
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
	
	if decaying:
		start_shape_decay()

func set_invisible(invisible):
	$Texture/AnimationPlayer.get_animation("create").track_set_enabled(1, invisible)
	$Texture/AnimationPlayer.get_animation("hit").track_set_enabled(3, invisible)


func start_shape_decay():
	var tween = $tween
	tween.interpolate_property(
		$Texture/Scale/Sprite, "self_modulate:v",
		null, 0,
		4.0, Tween.TRANS_CIRC, Tween.EASE_IN
	)
	tween.start()


func remove():
	if not can_remove():
		return
	
	emit_signal("removed")
	$Texture/AnimationPlayer.play("remove")
	yield($Texture/AnimationPlayer, "animation_finished")
	queue_free()

#func on_input_event(viewport, event, shape_idx):
#	if event.is_action_pressed("ui_accept"):
#		emit_sound(22.0)
#		$Texture/AnimationPlayer.stop()
#		$Texture/AnimationPlayer.play("just the sound")

func destroy():
	# TODO: "Destruction" animation
	$Texture/AnimationPlayer.play("remove")
	yield($Texture/AnimationPlayer, "animation_finished")
	queue_free()
