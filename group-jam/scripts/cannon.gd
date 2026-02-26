extends Node2D

@export var id : int

@onready var cannon_anim = find_child("cannon_animation")
@onready var blow_anim = find_child("blow_animation")

@onready var bullet = preload("res://scenes/bullet.tscn")
@onready var parry_bullet = preload("res://scenes/ParryBullets/parry_bullet_wall.tscn")

func shoot():
	cannon_anim.play("shoot")
	blow_anim.play("blow")
	create_bullet(1)
	await cannon_anim.animation_finished

func create_bullet(bullet_type):
	var new_bullet : Node
	match(bullet_type):
		1: new_bullet = bullet.instantiate()
		2: new_bullet = parry_bullet.instantiate()
	self.add_child(new_bullet)
