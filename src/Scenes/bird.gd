extends Area2D

func _process(delta: float) -> void:
	position.x -= get_parent().speed / 2
