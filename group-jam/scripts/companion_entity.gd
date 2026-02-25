extends CharacterBody2D
class_name Companion

const SPEED = 150.0

@onready var hurtbox = find_child("hurtbox")

@export var distance : int = 30

var target : Node
var target_position : Vector2
var type : int
var sprite : Sprite2D

func _ready():
	hurtbox.area_entered.connect(death)
	SignalBus.player_move.connect(find_target_position)
	
func _process(delta: float) -> void:
	target_reached()
	
	move_and_slide()
	
func find_target_position():
	target_position = -(self.global_position - target.global_position).normalized()
	velocity = target_position * SPEED
	
func target_reached():
	var target_distance = self.global_position.distance_to(target.global_position)
	if target_distance < distance:
		velocity.x = 0
		velocity.y = 0

func death(area : Node2D):
	if area.is_in_group("Bullet"):
		area.queue_free()
		CompanionLogic.kill_comp(self)
		
