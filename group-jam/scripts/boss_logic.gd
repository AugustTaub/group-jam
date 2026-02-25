extends Node2D

@onready var boss_anim = find_child("boss_animation")
@onready var hurtbox = find_child("hurtbox")
@onready var cannon_ancor = find_child("cannon_ancor")

var cannon_list : Array = []
var pattern : Array = [0,1,1,0,1]

var cannonList : Dictionary = {}#patternlist -> cannonlist for loop 


func _ready():
	hurtbox.area_entered.connect(convert_boss)
	init_cannon_list()
	

func init_cannon_list():
	for cannon in cannon_ancor.get_children():
		cannon_list.append(cannon)
		
func master_shoot(array : Array):
	var count = 0
	for cannon in cannon_list:
		if pattern[count] == 1:
			cannon.shoot()
		count += 1
		
func _on_timer_timeout() -> void:
	master_shoot(pattern)


func convert_boss(area : Area2D):
	if area.name == "ParryHitbox":
		boss_anim.play("boss_off")
		await boss_anim.animation_finished
		await get_tree().create_timer(3.0).timeout
		boss_anim.play("boss_on")
		await boss_anim.animation_finished
		boss_anim.play("boss_idle_converted")
