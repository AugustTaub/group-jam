extends CharacterBody2D
class_name PlayerController


@export var speed : float = 200.0
@export var knockback_power : float = 500.0

var is_parrying : bool = false 

func _ready():
	SignalBus.teleport_player.connect(teleport)
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
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var my_random_number = rng.randi_range(0, 2)
		SignalBus.create_conpanion.emit(my_random_number)

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

func switch_ability():
	if ability_type > ability_type_list.size() -2:
		ability_type = -1
	ability_type = ability_type_list[ability_type + 1]
	print("current ability: ",ability_type)
	
#creates projectile, that applies effect on landing	
func cast_ability():
	if CompanionLogic.has_comp(ability_type):
		CompanionLogic.remove_comp(ability_type)
		
		var new_ability_proj = ability_proj.instantiate()
		new_ability_proj.global_position = self.global_position
		new_ability_proj.ability_type = self.ability_type
		new_ability_proj.target_position = get_global_mouse_position()
		get_parent().add_child(new_ability_proj)
		
		print("cast ability: ",ability_type)

#inputlistener for ability cast and switch
@onready var ability_proj = preload("res://scenes/player_projectile.tscn")

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("cast_ability_mouse_left"):
		cast_ability()
	if Input.is_action_just_pressed("switch_ability_mouse_right"):
		switch_ability()	
		
		
func teleport(pos : Vector2):
	self.global_position = pos
