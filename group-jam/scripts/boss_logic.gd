extends Node2D

@onready var boss_anim = find_child("boss_animation")
@onready var tentacle_animation = find_child("tentacle_animation")
@onready var hurtbox = find_child("hurtbox")

func _ready():
	hurtbox.area_entered.connect(convert_boss)

func convert_boss(area : Area2D):
	if area.name == "ParryHitbox":
		boss_anim.play("boss_off")
		await boss_anim.animation_finished
		await get_tree().create_timer(2.0).timeout
		tentacle_animation.play("boss_hug")
		boss_anim.play("boss_on")
		
		await boss_anim.animation_finished
		boss_anim.play("boss_idle_converted")
