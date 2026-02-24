extends CharacterBody2D

@export var speed = 200.0

func _physics_process(_delta):
	var input_direction = Input.get_vector("left", "right", "forward", "back")
	
	var iso_velocity = Vector2(input_direction.x,input_direction.y * 0.5 )
	
	if iso_velocity.length() > 0:
		velocity = iso_velocity.normalized() * speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)
		
	move_and_slide()
