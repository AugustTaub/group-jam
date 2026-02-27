extends CharacterBody2D
class_name PlayerController

@onready var player_anim  = find_child("player_anim")
@onready var dust_anim_left  = find_child("dust_anim_left")
@onready var dust_anim_right  = find_child("dust_anim_right")
@onready var parry_anim  = find_child("parry_anim")
@onready var parry_hitbox  = find_child("ParryHitbox").get_child(0)
@onready var hurtbox  = find_child("hurtbox")

@export_range(0,2) var number_comp : int = 0
@export var parry_length : float = 0.3
@export var speedVal : float = 200.0
var speed : float = speedVal

#für Parry The Platypus und Knockback II
var can_move : bool = true:
	set(value):
		can_move = value
		if value == false:
			speed = 0
		else:
			speed = speedVal

@export var knockback_power : float = 500.0
var knockback_timer : float = 0.0
var gommemode: bool = false


#Suffering
#var dustPosX = -20
##var dustPosY = -3
#var dustPosXreverse = 2000d

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
	# wenn jemand diesen Kommentar ließt schuldet er mir einen Döner
	if knockback_timer > 0.0:
		knockback_timer -= _delta
		move_and_slide() 
		
		if knockback_timer <= 0.0:
			can_move = true
			gommemode = false
			self.modulate.a = 1.0
			hurtbox.get_child(0).set_deferred("disabled", false)
		return
	
	if not can_move:
		velocity = Vector2.ZERO 
		move_and_slide()
		return
	
	var input_direction = Input.get_vector("left", "right", "forward", "back")
	var iso_velocity = Vector2(input_direction.x, input_direction.y * 0.5)
	
	if iso_velocity.length() == 0:
		velocity = velocity.move_toward(Vector2.ZERO, speed)
	else:	
		velocity = iso_velocity.normalized() * speed
		SignalBus.player_move.emit()

		
	move_and_slide()
			
	if Input.is_action_just_pressed("ui_accept"):
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var my_random_number = rng.randi_range(0, 2)
		SignalBus.create_conpanion_by_id.emit(number_comp)

#TO-DO
# Fix für knockback wenn mult bullets hitten --> perma stun prblem wenn dur zu lang
#fixed
func knockback(direction: Vector2, duration: float, force: float):
	if gommemode:
		return
	
	gommemode = true
	
	#FUNCTION: Bitte umänder falls ne nötig, ist bis jetzt für player feedback, maybe ne blink animation wenn zeit ist
	self.modulate.a = 0.5
	var iso_direction = Vector2(direction.x, direction.y * 0.5).normalized()
	velocity = iso_direction * (knockback_power * force)
	
	knockback_timer = duration
	can_move = false
	
	hurtbox.get_child(0).set_deferred("disabled", true)
	parry_hitbox.set_deferred("disabled", true)


func parry():
	if not can_move: 
		return 
		
	can_move = false 
	parry_hitbox.disabled = false
	await get_tree().create_timer(parry_length).timeout
	parry_hitbox.disabled = true
	
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
