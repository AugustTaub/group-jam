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

#für Parry The Platypus und knockback
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


@export var parry_window: float = 0.3
@export var parry_delay: float = 0.5
var can_parry: bool = true

#@onready var dust_offset: float = $DustParticle.position.x
#var dust_flip: float = dust_offset + 15

#var dustPosX = -20
##var dustPosY = -3
#var dustPosXreverse = 2000

func _ready():
	SignalBus.teleport_player.connect(teleport)
	SignalBus.parried_bullet.connect(func():$parry_VFX.trigger_hit_vfx())
	
	CompanionLogic.player = self
	CompanionLogic.container = self.find_child("companion_container")
	


func _process(delta: float) -> void:
	player_animation()

## PLAYER ANIMATION
#TODO can_move mit einbinden bei idle 
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
	# wenn jemand diesen Kommentar ließt schuldet er mir einen Döner
	#BLOCK IST WICHTIG, NICHT LÖSCHEN VRO
	# VRO ich lösche nicht absichtlich zeug. das war der merge und das passiert öfter desto mehr zeug du in die process func rein haust und nicht in eigene Funktionen
	if knockback_timer > 0.0:
		knockback_timer -= delta
		move_and_slide() 
		
		#anim
		$alex_anims.skew += delta * 16
		if $alex_anims.skew > 90:
			$alex_anims.skew = -90
		
		
		if knockback_timer <= 0.0:
			#revert anim
			var tween = create_tween()
			tween.tween_property($alex_anims,"skew",0,0.15)
			dust_anim_left.show()
			dust_anim_right.show()
			
			
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
		
		
#	if velocity.x != 0:
#		player_anim.flip_h = velocity.x < 0
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
		var player_dist: float = child.global_position.distance_to(global_position)
		
		var speed_mult: float = 1
		var dir: Vector2 = Vector2.ZERO
		
		if dist >= 30:
			dir = child.global_position.direction_to(target_node.global_position)
			speed_mult = 1
		elif player_dist < 35:
			speed_mult = 0.5
			if player_dist < 25:
				dir = global_position.direction_to(child.global_position)
			else:
				dir = child.global_position.direction_to(global_position).rotated(deg_to_rad(90))
		
		if child.has_method("set_leg_flip"):
			if dir.x < 0:
				child.set_leg_flip(true)
			else:
				child.set_leg_flip(false)
		
		child.global_position +=  dir * delta * child.SPEED * speed_mult
		i += 1


#TO-DO
func knockback(direction: Vector2, duration: float, force: float):
	if gommemode:
		return
	
	Engine.time_scale = 1.0
	
	dust_anim_left.hide()
	dust_anim_right.hide()
	
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
	if not can_parry: 
		return 
	
	$parry_VFX.trigger_normal_vfx()
	
	can_parry = false 
	
	#slow down anstatt movement stop
	var tween = create_tween()
	speed = speedVal*0.01
	tween.tween_property(self,"speed",speedVal,parry_window*1.3).set_trans(Tween.TRANS_BOUNCE)
	
	
	$ParryHitbox/CollisionShape2D.set_deferred("disabled", false)
	await get_tree().create_timer(parry_window).timeout
	#parry_anim.play("player_parry")
	#await parry_anim.animation_finished
	$ParryHitbox/CollisionShape2D.set_deferred("disabled", true)
	can_move = true
	
	await get_tree().create_timer(parry_delay).timeout
	can_parry = true

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
	SignalBus.switch_companion_pressed.emit(active_companion_slot)

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
		#parry_anim.play("player_parry")
		parry()
		
func teleport(pos : Vector2):
	self.global_position = pos
