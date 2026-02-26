extends Control

var anims_running: bool = false
var queued_anim: bool = false
signal anims_done

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	SignalBus.game_started.connect(show)
	anims_done.connect(_on_anims_done)

func set_portraits(portraits: Array[Texture2D]):
	var i: int = 1
	
	while i <= 3:
		get_node(str(i)).get_node("tex").texture = portraits[i-1]
		
		i += 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		cycle_display()

func cycle_display():
	
	if anims_running: 
		queued_anim = true
		return
	
	anims_running = true
	
	var i: int = 1
	
	while i <= 3:
		var from_child: Control = get_node(str(i))
		
		var adj_i: int = i +1
		if adj_i > 3:
			adj_i = 1
		
		var to_child: Control = get_node(str(adj_i))
		
		
		var tween = create_tween()
		tween.set_parallel()
		tween.tween_property(from_child,"position",to_child.position,0.15)
		tween.tween_property(from_child,"scale",to_child.scale,0.15)
		tween.tween_property(from_child,"z_index",to_child.z_index,0.15)
		
		
		if i == 3:
			tween.finished.connect(func(): anims_done.emit())
		
		
		queued_anim = false
		i += 1

func _on_anims_done():
	anims_running = false
	if queued_anim: cycle_display()
