extends custom_window

@export var main_window: custom_window
@export var options_window: custom_window

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	
	
	var drag_margin: MarginContainer = find_child("drag_margin")
	drag_margin.gui_input.connect(_on_drag_margin_gui_input)
	
	var header: PanelContainer = find_child("header")
	header.gui_input.connect(_on_header_gui_input)

func appear():
	if visible : return
	show()
	scale = Vector2.ONE * 0.05
	
	var appeartween = create_tween()
	
	appeartween.tween_property(self,"scale",Vector2.ONE,0.2).set_trans(Tween.TRANS_BOUNCE)
	
	


func dissapear():
	
	scale = Vector2.ONE
	
	var dissapeartween = create_tween()
	
	dissapeartween.tween_property(self,"scale",Vector2.ONE* 0.05,0.1).set_trans(Tween.TRANS_BOUNCE)
	
	
	await dissapeartween.finished
	hide()
	


func _on_close_button_pressed():
	
	dissapear()
