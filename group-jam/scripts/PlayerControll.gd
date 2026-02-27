extends CharacterBody2D
class_name PlayerController

@onready var player_anim  = find_child("player_anim")
@onready var dust_anim_left  = find_child("dust_anim_left")
@onready var dust_anim_right  = find_child("dust_anim_right")
@onready var parry_anim  = find_child("parry_anim")
@onready var parry_hitbox  = find_child("ParryHitbox").get_child(0)
@onready var hurtbox  = find_child("hurtbox")

@export_range(0,2) var number_comp : int = 0
@export var speedVal : float = 200.0
var speed : float = speedVal

var active_companion_slot: int = 0

#für Parry The Platypus
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

#@onready var dust_offset: float = $DustParticle.position.x
#var dust_flip: float = dust_offset + 15

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

func _physics_process(delta):
	
	if knockback_timer > 0.0:
		knockback_timer -= delta
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
	
	companions_follow(delta)
	
	var input_direction = Input.get_vector("left", "right", "forward", "back")
	var iso_velocity = Vector2(input_direction.x, input_direction.y * 0.5)
	
	if iso_velocity.length() == 0:
		velocity = velocity.move_toward(Vector2.ZERO, speed)
		player_anim.play("player_idle")
		#$DustParticle.self_modulate = 0
	else:	
		velocity = iso_velocity.normalized() * speed
		player_anim.play("player_walk")
		SignalBus.player_move.emit()
		#$DustParticle.position.x = dustPosXreverse
		
		
	if velocity.x != 0:
		player_anim.flip_h = velocity.x < 0
		#$DustParticle.position.x = dustPosX
		
	move_and_slide()
			
	#if Input.is_action_just_pressed("ui_accept"):
	#	var rng = RandomNumberGenerator.new()
	#	rng.randomize()
	#	var my_random_number = rng.randi_range(0, 2)
	#	SignalBus.create_companion.emit(my_random_number)

func companions_follow(delta):
	var i: int = 0
	for child: Companion in $companion_container.get_children():
		var target_node: Node2D
		if i == 0:
			target_node = self 
		else:
			target_node = $companion_container.get_children()[i-1]
		
		var dist: float = child.global_position.distance_to(target_node.global_position)
		
		if dist >= 30:
			var dir: Vector2 = child.global_position.direction_to(target_node.global_position)
			child.global_position +=  dir * delta * child.SPEED
		
		i += 1


#TO-DO
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
	$ParryHitbox/CollisionShape2D.set_deferred("disabled", false)
	
	parry_anim.play("player_parry")
	await parry_anim.animation_finished
	$ParryHitbox/CollisionShape2D.set_deferred("disabled", true)
	
	can_move = true 

## ability use logic
#ability_type_list contains all types of companions
#	0 -> explosion
#	1 -> wall
#	2 -> teleport
var ability_type_list : Array = [0,1,2]
var ability_type : int = ability_type_list[0]

func switch_ability():
	active_companion_slot += 1
	if active_companion_slot >= CompanionLogic.max_companions:
		active_companion_slot = 0
	
	print("active_companion_slot",active_companion_slot)
	SignalBus.switch_companion_pressed.emit()

#creates projectile, that applies effect on landing	
func cast_ability():
	print(CompanionLogic.companion_dict[active_companion_slot])
	if CompanionLogic.companion_dict[active_companion_slot] != null:
		
		var selected_comp: Companion =  CompanionLogic.companion_dict[active_companion_slot]
		var new_ability_proj = ability_proj.instantiate()
		new_ability_proj.global_position = self.global_position
		new_ability_proj.ability_type = selected_comp.type
		new_ability_proj.target_position = get_global_mouse_position()
		get_parent().add_child(new_ability_proj)
		
		CompanionLogic.remove_comp(active_companion_slot)
		print("cast ability: ",ability_type)
		
		switch_ability()



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
