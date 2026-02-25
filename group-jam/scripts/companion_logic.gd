extends Node
class_name Compainions

var companion_list : Array[Companion]
var max_companions : int = 3
var player : Node

func _ready():
	SignalBus.create_conpanion.connect(add_comp)

func add_comp(type):
	if companion_list.size() < max_companions:
		var comp = preload("res://scenes/companion.tscn")
		var new_comp = comp.instantiate()
	
		if companion_list.size() == 0:
			new_comp.target = player
		else:
			new_comp.target = companion_list.back()
			
		new_comp.name = "companion" + str(companion_list.size())
		new_comp.global_position = player.global_position
		new_comp.type = type
		companion_list.append(new_comp)
		player.find_child("companion_container").add_child(companion_list.back())
		print(companion_list)
		
func remove_comp():
	pass
	
func rebind_comp(index : int):
	companion_list[index].queue_free()
	companion_list.remove_at(index)
	var pos = 0
	for comp in companion_list:
		if pos == 0:
			comp.target = player
		else:
			comp.target = companion_list[pos - 1]
		pos += 1
		print(pos,comp.name, comp.target.name)
	
func kill_comp(companion : Companion):
	var index = 0
	for comp in companion_list:
		if comp == companion:
			rebind_comp(index)
		index += 1
			
