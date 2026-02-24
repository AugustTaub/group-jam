extends Node
class_name Compainions

var companion_list : Array[Companion]
var player : Node

func add_comp(type):
	if companion_list.size() < 3:
		var comp = preload("res://scenes/companion.tscn")
		var new_comp = comp.instantiate()
	
		if companion_list.size() == 0:
			new_comp.target = player
		else:
			new_comp.target = companion_list.back()
		new_comp.global_position = player.global_position
		new_comp.type = type
		companion_list.append(1)
		companion_list.append(new_comp)
		add_child(new_comp)
		print(companion_list)

func remove_comp(comp):
	companion_list.erase(comp)
	pass
