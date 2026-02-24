extends CharacterBody2D
class_name PlayerController

@onready var logic = find_child("logic")

@export var speed = 200.0
@export var knockback_power: float = 500.0

func _ready():
	logic.player = self

func _physics_process(_delta):
	var input_direction = Input.get_vector("left", "right", "forward", "back")
	var iso_velocity = Vector2(input_direction.x, input_direction.y * 0.5)

	if iso_velocity.length() > 0:
		velocity = iso_velocity.normalized() * speed
		SignalBus.player_move.emit()
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)

	move_and_slide()

func knockback(source_velocity: Vector2):
	var knockback_direction = (source_velocity - velocity).normalized()
	var iso_knockback = Vector2(knockback_direction.x, knockback_direction.y * 0.5)

	velocity = iso_knockback.normalized() * knockback_power
	move_and_slide()


func canMove():
	pass
