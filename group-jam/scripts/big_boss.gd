extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalVars.boss_pos = global_position
	print("BOSS", GlobalVars.boss_pos)
