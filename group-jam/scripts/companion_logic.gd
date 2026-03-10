extends Node
class_name Compainions

var companion_dict : Dictionary
var max_companions : int = 3

#defined in Player
var player : Node
var container : Node

var current_active_comp_index: int = 0

func _ready():
	SignalBus.create_companion_by_id.connect(add_comp_by_id)
	SignalBus.create_companion_by_name.connect(add_comp_by_name)
	SignalBus.switch_companion_pressed.connect(_on_switch_companion_pressed)
	
	prepare_companion_dict()

func _on_switch_companion_pressed(new_index: int):
	current_active_comp_index = new_index

func prepare_companion_dict():
	var i: int = 0
	while i < max_companions:
		companion_dict[i]= null
		i += 1


##add
func add_comp_by_name(type):
	var id_type = -1
	match(type):
		"explosion": id_type = 0
		"barrier": id_type = 1
		"teleport": id_type = 2
	add_comp_by_id(id_type)
#adds companion at end of line
func add_comp_by_id(type):
	
	
	var key_arr: Array = companion_dict.keys()
	
	key_arr.push_front(key_arr.pop_at(key_arr.find(current_active_comp_index)))
	
	var new_key: int = 21332123
	for key in key_arr:
		if companion_dict[key] == null:
			new_key = key
			break
	
	if new_key == 21332123: 
		SignalBus.show_player_notification.emit("MAX COMPANIONS REACHED")
		return
	
	
	var comp = preload("res://scenes/companion.tscn")
	var new_comp = comp.instantiate()
	
	new_comp.name = "companion" + str(new_key)
	new_comp.global_position = player.global_position
	new_comp.type = type
	
	companion_dict[new_key] = new_comp
	container.add_child(new_comp)
	
	#anim
	var scaletween = create_tween()
	new_comp.scale = Vector2.ONE*0.1
	scaletween.tween_property(new_comp,"scale",Vector2.ONE,0.5).set_trans(Tween.TRANS_BOUNCE)
	
	
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
