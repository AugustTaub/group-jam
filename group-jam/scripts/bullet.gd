extends Node2D

@export var speed: float = 400.0

var move_direction = Vector2(-1, 1)

func _process(delta: float) -> void:
	var iso_velocity = Vector2(move_direction.x, move_direction.y * 0.5)
	self.position += iso_velocity.normalized() * speed * delta

func _on_bullet_hitbox_body_entered(_body: CharacterBody2D) -> void:
	print("hit")
	queue_free()
