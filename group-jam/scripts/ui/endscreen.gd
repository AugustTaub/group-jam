extends custom_window

@export var main_window: custom_window
@export var credits_window: custom_window
@export var companion_display: Control
@export var timernode: Control

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	
	var drag_margin: MarginContainer = find_child("drag_margin")
	drag_margin.gui_input.connect(_on_drag_margin_gui_input)
	
	var header: PanelContainer = find_child("header")
	header.gui_input.connect(_on_header_gui_input)
	
	SignalBus.open_thanks_window.connect(appear)
	

func appear():
	if visible : return
	show()
	companion_display.hide()
	timernode.running = false
	
	scale = Vector2.ONE * 0.05
	
	var appeartween = create_tween()
	
	appeartween.tween_property(self,"scale",Vector2.ONE,0.2).set_trans(Tween.TRANS_BOUNCE)
	
	get_tree().paused = true


func dissapear():
	
	scale = Vector2.ONE
	
	var dissapeartween = create_tween()
	
	dissapeartween.tween_property(self,"scale",Vector2.ONE* 0.05,0.1).set_trans(Tween.TRANS_BOUNCE)
	
	
	await dissapeartween.finished
	hide()
	


func _on_close_button_pressed():
	dissapear()
	await get_tree().create_timer(1).timeout
	appear()


func _on_credits_button_pressed():
	credits_window.appear()


func _on_exit_button_pressed():
	get_tree().quit()
