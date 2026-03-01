extends Node2D

@onready var boss_anim = find_child("boss_animation")
@onready var tentacle_animation = find_child("tentacle_animation")
@onready var hurtbox = find_child("hurtbox")
@onready var boss_glow = find_child("boss_glow")
var in_area = false

func _ready():
	GlobalVars.boss_pos = self.global_position
	print("BOSS", GlobalVars.boss_pos)
	boss_glow.visible = false
	hurtbox.area_entered.connect(convert_boss)

func _process(delta: float) -> void:
	if in_area and GlobalVars.player_parry_active:
		in_area = false
		SignalBus.stop_player_move.emit()
		boss_anim.play("boss_off")
		await boss_anim.animation_finished
		await get_tree().create_timer(2.0).timeout
		boss_glow.visible = true
		tentacle_animation.play("boss_hug")
		boss_anim.play("boss_on")
		
		await boss_anim.animation_finished
		boss_anim.play("boss_idle_converted")


func convert_boss(area : Area2D):
	if area.name == "ParryHitbox":
		in_area = true
