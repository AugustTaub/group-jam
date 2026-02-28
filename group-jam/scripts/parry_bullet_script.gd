extends CharacterBody2D

# 2dAnimatedSprites 
@onready var anim_sprite = find_child("anim_sprite")
@onready var parry_anim  = find_child("parry_anim")
@onready var hitbox  = find_child("hitbox")

#Bullet Types
@export_enum("explosion","barrier","teleport") var type : String

#Bullet Property
@export var speed: float = 200.0
@export var speed_mult: float = 1
@export var move_direction = Vector2(0, 0)
@export var invincible = 0.5

#for those who come after 
@export var knockback_duration: float = 0.3
@export var knockback_force: float = 1.0

#freeze frame checker
var in_freeze: bool = false

func _ready():
	hitbox.area_entered.connect(collide_area)
	hitbox.body_entered.connect(collide_body)
	anim_sprite.play(type + "_idle")
	await get_tree().create_timer(invincible).timeout
	hitbox.set_collision_mask_value(1,true)
	self.look_at(move_direction)

func _process(delta: float) -> void:
	velocity = move_direction.normalized() * speed * speed_mult
	move_and_slide()

func collide_area(area: Area2D) -> void:
	#if in_freeze:
	#	return
	#in_freeze = true
	#Engine.time_scale = 1.0
	
	#if in_freeze:
	#	return
	if area.name == "ParryHitbox":
		isParried() 
		return 
	#if area.name == "EffectiveHitboxCompanion":
	#	queue_free()
		
	var body = area.get_parent()
	if body.has_method("knockback"):
		var bullet_velocity = velocity
		body.knockback(bullet_velocity, knockback_duration, knockback_force)
		
	if not body.is_in_group("Bullet"):
		queue_free()
		

func collide_body(body: Node2D) -> void:
	if body.is_in_group("WorldCollision"):
		queue_free()
	
	
func isParried():
	if in_freeze:
		return
	in_freeze = true
	set_process(false) 
	set_deferred("monitoring", false)
	
	#TODO aus irgendeinem grund kann es sein das der character 
	#im freeze state bleibt. ich habe keine ahnung wieso oder warum
	# maybe gefixt, muss noch getestet werden
	# hatte was mit parry und knockback gleichzeitig zu tun
	#FreezeFrames
	Engine.time_scale = 0.05 
	await get_tree().create_timer(0.02).timeout 
	Engine.time_scale = 1.0
	
	rotation = 0 
	anim_sprite.visible = false 
	parry_anim.visible = true 
	
	SignalBus.create_companion_by_name.emit(type)
	SignalBus.parried_bullet.emit()
	
	parry_anim.play("player_parry")
	await parry_anim.animation_finished
	
	queue_free()
