extends CharacterBody2D
class_name PlayerController


@export var speed : float = 200.0
@export var knockback_power : float = 500.0

var is_parrying : bool = false 

func _ready():
	CompanionLogic.player = self
	CompanionLogic.container = self.find_child("companion_container")

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
		parry()
		SignalBus.create_conpanion.emit(1)

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

## ability use logic
#ability_type_list contains all types of companions
#	0 -> explosion
#	1 -> wall
#	2 -> teleport
var ability_type_list : Array = [0,1,2]
var ability_type : int = ability_type_list[0]

func ability_switch():
	if ability_type > ability_type_list.size() -2:
		ability_type = -1
	ability_type = ability_type_list[ability_type + 1]
	print("current ability: ",ability_type)
	
func cast_ability():
	if CompanionLogic.has_comp(ability_type):
		CompanionLogic.remove_comp(ability_type)
		match(ability_type):
			0:	cast_explosion()
			1:	cast_wall()
			2:	cast_teleport()
		print("cast ability: ",ability_type)

func cast_explosion():
	pass
func cast_wall():
	pass
func cast_teleport():
	pass
