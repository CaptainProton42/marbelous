extends Node2D

func set_fill(value : bool) -> void:
	$Fill.visible = value
	$AnimationPlayer.play("shake")

func is_filled() -> bool:
	return $Fill.visible