extends CanvasLayer

func _process(delta: float):
		if visible and Input.is_action_just_pressed("start"):
				emit_signal("restart_requested")

func _ready():
		# Make sure the signal is defined
		if not has_user_signal("restart_requested"):
				add_user_signal("restart_requested")
