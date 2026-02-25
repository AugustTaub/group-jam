extends Node2D

@onready var anim = find_child("animation")
@onready var shape = find_child("shape")

var duration = 5.0

func _ready() -> void:
	await get_tree().create_timer(duration).timeout
	anim.play("barrier_break")
	await anim.animation_finished
	get_parent().queue_free()
