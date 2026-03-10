extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func trigger_normal_vfx():
	$normal_particles.speed_scale = 1
	$normal_particles.emitting = true

func trigger_hit_vfx():
	
	$normal_particles.speed_scale = 1/Engine.time_scale
	$hit_particles.speed_scale = 1/Engine.time_scale
	
	$normal_particles.restart()
	$hit_particles.restart()
	$x_particles.restart()
	$o_particles.restart()
	
	$normal_particles.emitting = true
	$hit_particles.emitting = true
	$x_particles.emitting = true
	$o_particles.emitting = true
