extends custom_window

@export var options_window: custom_window
@export var credits_window: custom_window

# Called when the node enters the scene tree for the first time.
func _ready():
	appear()
	
	var drag_margin: MarginContainer = find_child("drag_margin")
	drag_margin.gui_input.connect(_on_drag_margin_gui_input)
	
	var header: PanelContainer = find_child("header")
	header.gui_input.connect(_on_header_gui_input)

func appear():
	show()
	get_parent().show()
	scale = Vector2.ONE * 0.05
	
	var appeartween = create_tween()
	
	appeartween.tween_property(self,"scale",Vector2.ONE,0.2).set_trans(Tween.TRANS_BOUNCE)
	
	get_tree().paused = true

func dissapear():
	options_window.dissapear()
	credits_window.dissapear()
	
	scale = Vector2.ONE
	
	var dissapeartween = create_tween()
	
	dissapeartween.tween_property(self,"scale",Vector2.ONE* 0.05,0.1).set_trans(Tween.TRANS_BOUNCE)
	
	await dissapeartween.finished
	
	hide()
	
	get_tree().paused = false


func _on_close_button_pressed():
	dissapear()
	await get_tree().create_timer(0.5).timeout
	position.x += randf_range(-250,250)
	position.x = clamp(position.x,0,1000)
	appear()


func _on_options_button_pressed():
	options_window.appear()


func _on_start_button_pressed():
	dissapear()
	await get_tree().create_timer(0.2).timeout
	get_parent().hide()


func _on_credits_button_pressed():
	credits_window.appear()
