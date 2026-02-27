extends Area2D

@export var speed: float = 200.0
@export var move_direction = Vector2(0, 0)

#knockknock
@export var knockback_duration: float = 0.3
@export var knockback_force: float = 1.0


func _process(delta: float) -> void:
	var iso_velocity = Vector2(move_direction.x, move_direction.y)
	self.global_position += self.global_position.direction_to( iso_velocity) * speed * delta

# TO-DO
# bis jetzt simpler Knockback, der ist aber arsch und
# für tests gedacht, guter muss noch implementiert werden
func _on_body_entered(body: Node2D) -> void:
	if body.has_method("knockback"):
		var bullet_velocity = self.global_position.direction_to(move_direction).normalized()
		body.knockback(bullet_velocity, knockback_duration, knockback_force)
	queue_free()
