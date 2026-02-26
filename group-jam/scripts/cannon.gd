extends Node2D

@export var enabled : bool = true
var can_shoot : bool = false

@export_enum("down","left","right","up") var direction : String = "down"
@export var interval : float = 1.0
@export_enum("single_straight", "three_spray") var pattern : String = "single_straight"

@onready var cannon_anim = find_child("cannon_animation")
@onready var blow_anim = find_child("blow_animation")
	
@onready var pattern_ancor = find_child("pattern_ancor")
@onready var pattern_position = find_child("pattern_position")
var pattern_node : Node2D

@onready var bullet = preload("res://scenes/bullet.tscn")
@onready var parry_bullet = preload("res://scenes/parry_bullet.tscn")

func _ready():
	instantiate_pattern()
	apply_direction()
	blow_anim.play("blow") # important because of selected startframe only first animation doesnt play
	cannon_anim.play("start_" + direction)
	await cannon_anim.animation_finished
	can_shoot = true
		
func _process(delta: float) -> void:
	if enabled == true:
		if can_shoot == true:
			can_shoot = false
			shoot()
			await get_tree().create_timer(interval).timeout
			can_shoot = true

#play anim and shoot bullet
func shoot():
	cannon_anim.play("shoot_" + direction)
	fill_pattern()
	blow_anim.play("blow")
	await cannon_anim.animation_finished

#instantiate bullet
func create_bullet(bullet_type : int, target : Vector2):
	var new_bullet : Node
	match(bullet_type):
		1: new_bullet = bullet.instantiate()
		2: new_bullet = parry_bullet.instantiate()
	new_bullet.move_direction = target
	self.add_child(new_bullet)

func fill_pattern():
	for vector in pattern_node.get_children():
		var target = vector.get_child(0)
		var new_target =  target.global_position - self.global_position
		create_bullet(1,new_target * 1000)

#sets new direction for vectors of bullets based on rotation selected
func apply_direction():
	var pattern_rotation : int = 0
	match(direction):
		"down": pattern_rotation = 45 + 10
		"left": pattern_rotation = 135 + 10
		"right": pattern_rotation = -135 - 10
		"up": pattern_rotation = 225 + 10
		
	pattern_ancor.rotation_degrees = pattern_rotation
	blow_anim.global_position = pattern_position.global_position

func instantiate_pattern():
	
	var pattern_type : PackedScene = null
	match(pattern):
		"single_straight": pattern_type = preload("res://scenes/patterns/pattern_single_straight.tscn")
		"three_spray": pattern_type = preload("res://scenes/patterns/pattern_three_spray.tscn")
	
	var new_pattern = pattern_type.instantiate()
	pattern_position.add_child(new_pattern)
	pattern_node = new_pattern
	
	
