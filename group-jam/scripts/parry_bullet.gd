extends Area2D

signal isParriedVal(value: int)

@onready var anim_sprite = find_child("anim_sprite")

@export_enum("explosion","barrier","teleport") var type : String
@export var speed: float = 200.0
@export var move_direction = Vector2(0, 0)

func _process(delta: float) -> void:
	var iso_velocity = Vector2(move_direction.x, move_direction.y)
	self.global_position += self.global_position.direction_to( iso_velocity) * speed * delta
	look_at(-move_direction)
func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	anim_sprite.play(type + "_idle")

func _on_area_entered(area: Area2D) -> void:
	if area.name == "ParryHitbox":
		print("parried Bullet")
		isParried()   
		
	if area.name == "EffectiveHitboxCompanion":
		print("Effect Hit")
		queue_free()
		
		
# TO-DO
# bis jetzt simpler Knockback, der ist aber arsch und 
# für tests gedacht, guter muss noch implementiert werden
func _on_body_entered(body: CharacterBody2D) -> void:
	#print(type, " hit")
	if body.has_method("knockback"):
		var bullet_velocity = move_direction.normalized() * speed
		body.knockback(bullet_velocity)
	queue_free()
	
func isParried():
	print("parry")
	isParriedVal.emit(1)
	queue_free()
