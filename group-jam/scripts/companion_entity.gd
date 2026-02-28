extends CharacterBody2D
class_name Companion

const SPEED = 150.0

@onready var sprites = find_child("sprites")

@export var distance : int = 30

var target : Node
var target_position : Vector2
var type : int
var current_sprite

func _ready():
	select_sprite()
	
func select_sprite():
	for sprite in sprites.get_children():
		sprite.visible = false
		if sprite.name == "sprite_" + str(type):
			current_sprite = sprite
	current_sprite.visible = true
	
		
