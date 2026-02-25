extends Node2D

@export var speed: float = 200.0
var move_direction = Vector2(-1, 1)

func _process(delta: float) -> void:
	var iso_velocity = Vector2(move_direction.x, move_direction.y * 0.5)
	self.position += iso_velocity.normalized() * speed * delta

# TO-DO
# bis jetzt simpler Knockback, der ist aber arsch und 
# für tests gedacht, guter muss noch implementiert werden
func _on_body_entered(body: Node2D) -> void:
	if body.has_method("knockback"):
		var bullet_velocity = move_direction.normalized() * speed
		body.knockback(bullet_velocity)
	
	print("hit")
	queue_free()
