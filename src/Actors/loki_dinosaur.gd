extends CharacterBody2D

const GRAVITY : int = 4200
const JUMP_SPEED : int = -1800

func _physics_process(delta: float) -> void:
	var is_jump_interrupted := Input.is_action_just_released("jump") and velocity.y < 0.0
	velocity.y += GRAVITY * delta
	if is_on_floor():
		if not get_parent().game_running:
			$AnimatedSprite2D.play("idle")
		else:
			$RunCollision.disabled = false
			# Jump logic
			if Input.is_action_just_pressed("jump"):
				velocity.y = JUMP_SPEED  # Apply the jump speed to the character's vertical velocity
				$JumpSound.play()
			elif Input.is_action_pressed("duck"):
				$AnimatedSprite2D.play("duck")
				$RunCollision.disabled = true
			else:
				$AnimatedSprite2D.play("run")
	else:
		if is_jump_interrupted:
			velocity.y = 0  # Interrupt the jump by stopping the upward movement
			$AnimatedSprite2D.play("jump")

	move_and_slide()
