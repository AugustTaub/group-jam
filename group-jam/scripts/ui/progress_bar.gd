extends ProgressBar

var start_boss_dist: float
var boss_dist: float

var is_checking: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	SignalBus.game_started.connect(show)
	value = 0
	
	await SignalBus.game_started
	await SignalBus.player_move
	start_boss_dist = GlobalVars.player_pos.distance_to(GlobalVars.boss_pos)
	is_checking = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):#
	if is_checking:
		var new_val: float = 100-(get_boss_dist()/start_boss_dist * 100)
		value = new_val


func _on_value_changed(new_value):
	%player_icon.position.x = (size.x * (new_value/max_value))-0.632*%player_icon.size.x

func get_boss_dist() -> float:
	return GlobalVars.player_pos.distance_to(GlobalVars.boss_pos)
