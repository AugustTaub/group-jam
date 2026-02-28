extends ProgressBar


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	SignalBus.game_started.connect(show)
	value = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_value_changed(new_value):
	%player_icon.position.x = (size.x * (new_value/max_value))-0.632*%player_icon.size.x
