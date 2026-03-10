extends RichTextLabel

var delta_timer: float = 0

var secs: int = 0
var mins: int = 0

var running = false

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.player_move.connect(func():running = true)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not running: return
	
	if delta_timer >= 1:
		secs += 1
		if secs >= 60:
			mins += 1
			secs = 0
		delta_timer = 0
	
	var secs_string: String
	
	if secs <= 9:
		secs_string = "0"+ str(secs)
	else:
		secs_string = str(secs)
	
	
	var mins_string: String
	if mins <= 9:
		mins_string = "0"+ str(mins)
	else:
		mins_string = str(mins)
	
	var end_string: String = "TIME: " + mins_string + ":" + secs_string
	
	text = end_string
	
	delta_timer += delta
