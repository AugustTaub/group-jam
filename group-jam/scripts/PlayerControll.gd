extends CharacterBody2D
class_name PlayerController

@onready var logic = find_child("logic")

@export var speed = 200.0

func _ready():
	logic.player = self

func _physics_process(_delta):
	var input_direction = Input.get_vector("left", "right", "forward", "back")
	
	var iso_velocity = Vector2(input_direction.x,input_direction.y * 0.5 )
	
	if iso_velocity.length() > 0:
		velocity = iso_velocity.normalized() * speed
		SignalBus.player_move.emit()
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)
		
	move_and_slide()
	
	if Input.is_action_just_pressed("ui_accept"):
		logic.add_comp("dd")
