extends Node2D

@onready var anim = find_child("animation")
@onready var shape = find_child("shape")
@onready var animationPlayer = $AnimationWall

var duration = 5.0

# TO-DO
#Jetziges Problem: Wenn diese weggeht, aber eine neue wall gespawnt wird
# dann wird trotzdem eine CollisionBox aktiviert
# das gute ist aber die ist disabled (wegen anim)
# das muss bestenfalls noch geändert werden
func _ready() -> void:
	await get_tree().create_timer(duration).timeout
	#anim.play("barrier_break")
	animationPlayer.play("barrier_break")
	await anim.animation_finished
	#get_parent().queue_free()
	queue_free()
