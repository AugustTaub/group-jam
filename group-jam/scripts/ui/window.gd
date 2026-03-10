extends PanelContainer

class_name custom_window

var mouse_in_header: bool = false
var held: bool = false
var hold_offset: Vector2 = Vector2.ZERO

var resizing: bool = false
var resize_dif: Vector2 = Vector2.ZERO

var old_pos: Vector2 = Vector2.ZERO
var mouse_rel_vel: Vector2 = Vector2.ZERO

var inner_resize: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	


func _process(delta):
	
	if held:
		global_position = get_global_mouse_position() + hold_offset
	
	if resizing:
		var adj_vel: Vector2 = mouse_rel_vel
		
		
		if inner_resize:
			print("IN")
			size -= adj_vel
			global_position += adj_vel
			
		else:
			print("OUT")
			size += adj_vel
		
	
	
	mouse_rel_vel = get_global_mouse_position() - old_pos
	old_pos = get_global_mouse_position()
	


func _on_header_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		hold_offset = global_position - get_global_mouse_position()
		held = true
	
	
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and not event.pressed:
		held = false


func _on_drag_margin_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT :
		resizing = true
		
		var mpos: Vector2 = get_global_mouse_position()
		var cpos: Vector2 = global_position
		
		resize_dif = mpos-cpos
		
		var w_size: Vector2 = %window_patch.size
		
		if resize_dif.x < w_size.x and resize_dif.y < w_size.y:
			inner_resize = true
		else:
			inner_resize = false
	
	
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and not event.pressed:
		resizing = false
