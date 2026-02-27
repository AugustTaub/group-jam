extends Area2D


@onready var anim_sprite = find_child("anim_sprite")

@export_enum("explosion","barrier","teleport") var type : String
@export var speed: float = 200.0
@export var move_direction = Vector2(0, 0)

#for those who come after
@export var knockback_duration: float = 0.3
@export var knockback_force: float = 1.0

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
# zu 90 % gefixt, nur noch perma stun problem muss angeschaut werden
#fixed
func _on_body_entered(body: CharacterBody2D) -> void:
	if body.has_method("knockback"):
		var bullet_velocity = self.global_position.direction_to(move_direction).normalized()
		body.knockback(bullet_velocity, knockback_duration, knockback_force)
	queue_free()

#TODO bitte den parry fixen karl, ich habe keinen schmarm was da übergeben werden soll lol
func isParried():
	#print("hitted parry mit " + "Key " + key + "Type " + type)
	SignalBus.added_companion.emit(0, type)
	queue_free()
