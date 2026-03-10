extends custom_window

@export var pause_window: custom_window
@export var main_window: custom_window


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
	
	get_tree().paused = true


func dissapear():
	
	scale = Vector2.ONE
	
	var dissapeartween = create_tween()
	
	dissapeartween.tween_property(self,"scale",Vector2.ONE* 0.05,0.1).set_trans(Tween.TRANS_BOUNCE)
	
	
	
	await dissapeartween.finished
	hide()
	
	if not main_window.visible:
		get_tree().paused = false


func _on_close_button_pressed():
	dissapear()


func _on_music_slider_value_changed(value):
	var value_in_db: float = (1-value) * -15
	
	AudioServer.set_bus_volume_db(1, value_in_db)


func _on_vfx_slider_value_changed(value):
	var value_in_db: float = (1-value) * -15
	
	AudioServer.set_bus_volume_db(2, value_in_db)
	
	SignalBus.play_audio.emit("blup")


func _on_music_toggle_toggled(toggled_on):
	AudioServer.set_bus_mute(1,toggled_on)
