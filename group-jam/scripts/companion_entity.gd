extends CharacterBody2D
class_name Companion

const SPEED = 150.0

@onready var hurtbox = find_child("hurtbox")
@onready var sprites = find_child("sprites")

@export var distance : int = 30

var target : Node
var target_position : Vector2
var type : int
var current_sprite

func _ready():
	hurtbox.area_entered.connect(death)
	select_sprite()
	
func select_sprite():
	for sprite in sprites.get_children():
		sprite.visible = false
		if sprite.name == "sprite_" + str(type):
			current_sprite = sprite
	current_sprite.visible = true
	

func _process(delta: float) -> void:
	return


func death(area : Node2D):
	if area.is_in_group("Bullet"):
		area.queue_free()
		CompanionLogic.kill_comp(self)
		
