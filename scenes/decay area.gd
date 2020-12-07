extends Area2D


#func _ready():
#	$collision.polygon = $fill.polygon

func _on_decay_area_body_entered(body):
	print("body entered")
