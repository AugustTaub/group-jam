extends CharacterBody2D
class_name PlayerController


@export var speed : float = 200.0
@export var knockback_power : float = 500.0

var is_parrying : bool = false 

func _ready():
	CompanionLogic.player = self

func _physics_process(_delta):
	var input_direction = Input.get_vector("left", "right", "forward", "back")
	var iso_velocity = Vector2(input_direction.x, input_direction.y * 0.5)

	if iso_velocity.length() > 0:
		velocity = iso_velocity.normalized() * speed
		SignalBus.player_move.emit()
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)

	move_and_slide()

	if Input.is_action_just_pressed("ui_accept"):
		SignalBus.create_conpanion.emit("dd")


#TO-DO
func knockback(source_velocity: Vector2):
	var knockback_direction = (source_velocity - velocity).normalized()
	var iso_knockback = Vector2(knockback_direction.x, knockback_direction.y * 0.5)

	velocity = iso_knockback.normalized() * knockback_power
	move_and_slide()
	


func parry():
	is_parrying = true
	await get_tree().create_timer(0.2).timeout
	is_parrying = false




#func canMove():
#	pass
