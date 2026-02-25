extends Node2D

@onready var anim = find_child("animation")
@onready var shape = find_child("shape")

func _ready() -> void:
	anim.play("explode")
	await anim.animation_finished
	get_parent().queue_free()
