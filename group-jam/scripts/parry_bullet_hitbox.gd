extends Area2D

signal isParriedWall(value: String)

@export var speed: float = 400.0
var move_direction = Vector2(-1, 1)

func _process(delta: float) -> void:
	var iso_velocity = Vector2(move_direction.x, move_direction.y * 0.5)
	self.position += iso_velocity.normalized() * speed * delta

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area.name == "ParryHitbox":
		print("parry")
		isParried()   


# TO-DO
# bis jetzt simpler Knockback, der ist aber arsch und 
# für tests gedacht, guter muss noch implementiert werden
func _on_body_entered(body: CharacterBody2D) -> void:	
	if body.has_method("knockback"):
		var bullet_velocity = move_direction.normalized() * speed
		body.knockback(bullet_velocity)
		
	print("Hit Parry")
	queue_free()

func isParried():
	print("parry")
	isParriedWall.emit("wall")
	queue_free()
