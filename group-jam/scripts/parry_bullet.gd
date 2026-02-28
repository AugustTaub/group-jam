extends Area2D

# 2dAnimatedSprites 
@onready var anim_sprite = find_child("anim_sprite")
@onready var parry_anim  = find_child("parry_anim")


#Bullet Types
@export_enum("explosion","barrier","teleport") var type : String

#Bullet Property
@export var speed: float = 200.0
@export var move_direction = Vector2(0, 0)

#for those who come after 
@export var knockback_duration: float = 0.3
@export var knockback_force: float = 1.0

#freeze frame checker
var in_freeze: bool = false


func _process(delta: float) -> void:
	var iso_velocity = Vector2(move_direction.x, move_direction.y)
	self.global_position += self.global_position.direction_to( iso_velocity) * speed * delta
	look_at(-move_direction)

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	anim_sprite.play(type + "_idle")

func _on_area_entered(area: Area2D) -> void:
	if in_freeze:
		return
	
	if area.name == "ParryHitbox":
		#print("parried Bullet")
		isParried()   
		
	if area.name == "EffectiveHitboxCompanion":
		#print("Effect Hit")
		queue_free()
		
		

func _on_body_entered(body: CharacterBody2D) -> void:
	if in_freeze:
		return
	
	in_freeze = true
	Engine.time_scale = 1.0
	
	if body.has_method("knockback"):
		var bullet_velocity = self.global_position.direction_to(move_direction).normalized()
		body.knockback(bullet_velocity, knockback_duration, knockback_force)
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
