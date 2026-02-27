extends Node
class_name Compainions

var companion_dict : Dictionary
var max_companions : int = 3

#defined in Player
var player : Node
var container : Node

func _ready():
	SignalBus.create_companion.connect(add_comp)
	
	prepare_companion_dict()

func prepare_companion_dict():
	var i: int = 0
	while i < max_companions:
		companion_dict[i]= null
		i += 1


##add
#adds companion at end of line
func add_comp(type):
	
	var new_key: int = 21332123
	for key in companion_dict.keys():
		if companion_dict[key] == null:
			new_key = key
			break
		
	
	if new_key == 21332123: return
	
	
	var comp = preload("res://scenes/companion.tscn")
	var new_comp = comp.instantiate()
	
	new_comp.name = "companion" + str(new_key)
	new_comp.global_position = player.global_position
	new_comp.type = type
	
	companion_dict[new_key] = new_comp
	container.add_child(new_comp)
	
	SignalBus.added_companion.emit(new_key, type)
	

##remove
#calls rebind_comp() by Companiontybe
func kill_comp(companion : Companion):
	var index: int = companion_dict.find_key(companion)
	if index != null:
		remove_comp(index)

func remove_comp(index: int):
	if companion_dict.has(index):
		companion_dict[index].queue_free()
		companion_dict[index] == null
		SignalBus.removed_companion.emit(index)

func has_comp(type):
	pass
