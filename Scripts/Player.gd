extends CharacterBody2D

# Definig the class name, because this way we can identify the type of body in area2D
class_name Player


const SPEED = 400.0


func _physics_process(delta: float) -> void:
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("right"):
		velocity.x += 1
	if Input.is_action_pressed("left"):
		velocity.x -= 1
	if Input.is_action_pressed("down"):
		velocity.y += 1
	if Input.is_action_pressed("up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * SPEED
		$AnimationPlayer.play("walk")
	else:
		$AnimationPlayer.stop()
	
	if velocity.x > 0:
		$Image.flip_h = false
	else:
		$Image.flip_h = true
	
	position += velocity * delta
	move_and_slide()
