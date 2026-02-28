extends CharacterBody2D

@onready var sprites = find_child("sprites")
@onready var hitbox = find_child("hitbox")

var speed = 200.0

var ability_type : int
var target_position : Vector2
var start_position : Vector2
var move_direction = Vector2(target_position)		
var current_sprite = null

var not_active = true

func _ready():
	hitbox.body_entered.connect(collide)
	start_position = self.global_position
	move_direction = Vector2(target_position)
	select_sprite()

func select_sprite():
	for sprite in sprites.get_children():
		sprite.visible = false
		if sprite.name == "sprite_" + str(ability_type):
			current_sprite = sprite
	current_sprite.visible = true

func _physics_process(delta: float) -> void:
	if self.global_position.distance_to(target_position) > speed/15:
		var iso_velocity = Vector2(move_direction.x, move_direction.y)
		self.global_position += self.global_position.direction_to( iso_velocity) * speed * delta
	else:
		hit_target()
	
	#place_sprite(delta)
	
	move_and_slide()

func hit_target():
	if self.global_position.distance_to(target_position) < speed/11:
		if not_active == true:
			apply_ability_effect(ability_type)
			not_active = false

func apply_ability_effect(ability_type : int):
	match(ability_type):
		0: cast_explosion()
		1: cast_wall()
		2: cast_teleport()
		
	
func cast_explosion():
	var explosion = preload("res://scenes/companion_objects/explosion.tscn")
	var new_exlposion = explosion.instantiate()
	add_child(new_exlposion)
	current_sprite.visible = false
	
func cast_wall():
	var wall = preload("res://scenes/companion_objects/wall.tscn")
	var new_wall = wall.instantiate()
	new_wall.duration = 5.0
	add_child(new_wall)
	current_sprite.visible = false
	
func cast_teleport():
	current_sprite.play("teleport_break")
	await current_sprite.animation_finished
	SignalBus.teleport_player.emit(self.global_position)
	self.queue_free()

func place_sprite(delta : float):
	var max_distance = abs(target_position.x - start_position.x)
	var distance = abs(target_position.x - self.global_position.x)
	if distance > max_distance/2:
		var sprite_direction = -1
		var iso_velocity = Vector2(sprite_direction,sprite_direction * 0.5)
		sprites.global_position.y += sprites.global_position.direction_to( iso_velocity).y * speed * 2 * delta
	elif distance < max_distance/2:
		var sprite_direction = 1
		var iso_velocity = Vector2(sprite_direction,sprite_direction * 0.5)
		sprites.global_position.y += sprites.global_position.direction_to( iso_velocity).y * speed * 2 * delta

func collide(body : Node2D):
	if body.is_in_group("Player"):
		print("hy")
	queue_free()
