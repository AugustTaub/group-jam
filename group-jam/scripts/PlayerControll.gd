extends CharacterBody2D
class_name PlayerController

@onready var player_anim  = find_child("player_anim")
@onready var dust_anim_left  = find_child("dust_anim_left")
@onready var dust_anim_right  = find_child("dust_anim_right")
@onready var parry_anim  = find_child("parry_anim")
@onready var parry_hitbox  = find_child("ParryHitbox").get_child(0)

@export_range(0,2) var number_comp : int = 0
@export var parry_length : float = 0.3
@export var speedVal : float = 200.0
var speed : float = speedVal

#für Parry The Platypus
var can_move : bool = true:
	set(value):
		can_move = value
		if value == false:
			speed = 0
		else:
			speed = speedVal

@export var knockback_power : float = 500.0



#var dustPosX = -20
##var dustPosY = -3
#var dustPosXreverse = 2000

func _ready():
	SignalBus.teleport_player.connect(teleport)
	CompanionLogic.player = self
	CompanionLogic.container = self.find_child("companion_container")


func _process(delta: float) -> void:
	player_animation()

## PLAYER ANIMATION
func player_animation():
	var motion_vector = Input.get_vector("left", "right", "forward", "back")
	if motion_vector:
		player_anim.play("player_walk")
		if motion_vector.x < 0:
			player_anim.flip_h = true
			dust_anim_right.play("player_dust")
		else:
			player_anim.flip_h = false
			dust_anim_left.play("player_dust")
	else:
		player_anim.play("player_idle")

func _physics_process(_delta):
	if not can_move:
		velocity = Vector2.ZERO 
		move_and_slide()
		return
	
	var input_direction = Input.get_vector("left", "right", "forward", "back")
	var iso_velocity = Vector2(input_direction.x, input_direction.y * 0.5)
	
	if iso_velocity.length() == 0:
		velocity = velocity.move_toward(Vector2.ZERO, speed)
		#animation.play("idle")
		#$DustParticle.self_modulate = 0
	else:	
		velocity = iso_velocity.normalized() * speed
		#animation.play("Running_new")
		SignalBus.player_move.emit()
		#$DustParticle.position.x = dustPosXreverse

		
#	if velocity.x != 0:
#		$PlayerRun.flip_h = velocity.x < 0
		#$DustParticle.position.x = dustPosX
		
	move_and_slide()
			
	if Input.is_action_just_pressed("ui_accept"):
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var my_random_number = rng.randi_range(0, 2)
		SignalBus.create_conpanion_by_id.emit(number_comp)

#TO-DO
func knockback(source_velocity: Vector2):
	var knockback_direction = (source_velocity - velocity).normalized()
	var iso_knockback = Vector2(knockback_direction.x, knockback_direction.y * 0.5)

	velocity = iso_knockback.normalized() * knockback_power
	move_and_slide()
	
func parry():
	if not can_move: 
		return 
		
	can_move = false 
	parry_hitbox.disabled = false
	await get_tree().create_timer(parry_length).timeout
	parry_hitbox.disabled = true
#	$ParryHitbox/CollisionShape2D.set_deferred("disabled", false)
	
#	animation.play("parry")
#	await animation.animation_finished
#	$ParryHitbox/CollisionShape2D.set_deferred("disabled", true)
	
	can_move = true 

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
		
	if Input.is_action_just_pressed("parry_v"):
		print("parry_button")
		parry_anim.play("player_parry")
		parry()
		
func teleport(pos : Vector2):
	self.global_position = pos
