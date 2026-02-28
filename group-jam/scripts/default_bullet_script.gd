extends CharacterBody2D

var speed: float = 200.0
@export var move_direction = Vector2(0, 0)
@export var invincible : float = 0.5 # time of wall-collision immunity after spawn
@export var speed_mult : float = 1.0
#var lifetime : float = 10.0

#knockknock
@export var knockback_duration: float = 0.3
@export var knockback_force: float = 1.0

@onready var hitbox = find_child("hitbox")

func _ready() -> void:
	hitbox.body_entered.connect(colliding_body)
	hitbox.area_entered.connect(colliding_area)
	
	await get_tree().create_timer(invincible).timeout
	hitbox.set_collision_mask_value(1,true)
	
func _physics_process(delta: float) -> void:
	velocity = move_direction.normalized() * speed * speed_mult
	move_and_slide()
	
	
func colliding_body(body: Node2D) -> void:
	if body.is_in_group("WorldCollision"):
		queue_free()

func colliding_area(area: Area2D) -> void:
	var body = area.get_parent()
	if body.has_method("knockback"):
		var bullet_velocity = velocity
		body.knockback(bullet_velocity, knockback_duration, knockback_force)
	if not body.is_in_group("Bullet"):
		queue_free()
