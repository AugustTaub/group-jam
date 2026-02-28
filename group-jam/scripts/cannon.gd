#@tool
extends Node2D
@export var enabled : bool = true
var can_shoot : bool = false

@export_category("direction and pattern")
@export_enum("down","left","right","up") var direction : String = "down" #:
	#set(new_direction):
	#	new_direction = direction
	#	set_animation(new_direction)
@export_enum("single_straight", "three_spray", "five_spray", "180_cover") var pattern : String = "single_straight"
@export var delay : float = 0.0

@export_category("bullet_parameter")
@export_range(0,100) var shots_per_parry : int = 1.0 # amount of bullets fired before 1 parryable bullet fires
var current_shot : int = 1
@export var interval : float = 1.0
@export_enum("random","explosion","barrier","teleport") var parry_type : String = "random"
@export var speed_multiplier: float = 1


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
	set_animation(direction)
	blow_anim.play("blow") # important because of selected startframe only first animation doesnt play
	cannon_anim.play("start")
	await cannon_anim.animation_finished
	await get_tree().create_timer(delay).timeout
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
	cannon_anim.play("shoot")
	fill_pattern()
	blow_anim.play("blow")
	await cannon_anim.animation_finished

#instantiate bullet
func create_bullet(bullet_type : String, target : Vector2):
	var r = RandomNumberGenerator.new()
	var type : String = ""
	if parry_type == "random":
		match(r.randi_range(0, 2)):
			0: type = "explosion"
			1: type = "barrier"
			2: type = "teleport"
		r.randomize()
	else:
		type = parry_type
		
	var new_bullet : Node
	if bullet_type == "default":
		new_bullet = bullet.instantiate()
	elif bullet_type == "parry":
		new_bullet = parry_bullet.instantiate()
		new_bullet.type = type
	new_bullet.move_direction = target
	new_bullet.speed_mult = speed_multiplier
	self.add_child(new_bullet)
	
#gott bewahre, dass es funktioniert "\_(-_-)_/"
func fill_pattern():
	for vector in pattern_node.get_children():
		var target = vector.get_child(0)
		var new_target =  (target.global_position - self.global_position)  * 1000
		if shots_per_parry == current_shot:	
			create_bullet("parry",new_target)
			current_shot = 0
		else:
			create_bullet("default",new_target)
		current_shot += 1

#sets new direction for vectors of bullets based on rotation selected
func apply_direction():
	var pattern_rotation : int = 0
	match(direction):
		"down": pattern_rotation = 50
		"left": pattern_rotation = 115
		"right": pattern_rotation = 295
		"up": pattern_rotation = -120
		
	pattern_ancor.rotation_degrees = pattern_rotation
	blow_anim.global_position = pattern_position.global_position

func instantiate_pattern():
	
	var pattern_type : PackedScene = null
	match(pattern):
		"single_straight": pattern_type = preload("res://scenes/patterns/pattern_single_straight.tscn")
		"three_spray": pattern_type = preload("res://scenes/patterns/pattern_three_spray.tscn")
		"five_spray": pattern_type = preload("res://scenes/patterns/pattern_five_spray.tscn")
		"180_cover": pattern_type = preload("res://scenes/patterns/pattern_180_cover.tscn")
	
	var new_pattern = pattern_type.instantiate()
	pattern_position.add_child(new_pattern)
	pattern_node = new_pattern
	

func set_animation(new_direction : String):
	cannon_anim = find_child("cannon_animation_" + new_direction)
	var animations = find_child("animations")
	for sprite in animations.get_children():
		sprite.visible = false
	cannon_anim.visible = true
