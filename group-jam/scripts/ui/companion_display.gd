extends Control

var anims_running: bool = false
var queued_anim: bool = false
signal anims_done

var preloaded_companion_tex0: Texture2D = preload("res://2D/Sprites/projectile_explosion_single.png")
var preloaded_companion_tex1: Texture2D = preload("res://2D/Sprites/projectile_gum_single.png")
var preloaded_companion_tex2: Texture2D = preload("res://2D/Sprites/projectile_teleport_single.png")

var active_display_index: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	SignalBus.game_started.connect(show)
	SignalBus.switch_companion_pressed.connect(cycle_display)
	SignalBus.added_companion.connect(set_portrait)
	SignalBus.removed_companion.connect(clear_portrait)
	
	anims_done.connect(_on_anims_done)

func set_portrait(portrait_index: int, type_index: int):
	var portrait_node: TextureRect = get_node(str(portrait_index)).get_node("tex")
	
	if portrait_node != null:
		var new_portrait: Texture2D
		match  type_index:
			0:
				new_portrait = preloaded_companion_tex0
			1:
				new_portrait = preloaded_companion_tex1
			2:
				new_portrait = preloaded_companion_tex2
		
		portrait_node.texture = new_portrait
		portrait_node.show()

func clear_portrait(portrait_index: int):
	var portrait_node: TextureRect = get_node(str(portrait_index)).get_node("tex")
	if portrait_node != null:
		portrait_node.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#if Input.is_action_just_pressed("switch_ability_mouse_right"):
		#cycle_display()

func cycle_display():
	
	if anims_running: 
		queued_anim = true
		return
	
	anims_running = true
	
	active_display_index += 1
	if active_display_index > 2:
		active_display_index = 0
	
	print("active_display_index",active_display_index)
	
	var i: int = 0
	
	while i <= 2:
		var from_child: Control = get_node(str(i))
		
		var adj_i: int = i - 1
		if adj_i < 0:
			adj_i = 2 
		
		var to_child: Control = get_node(str(adj_i))
		
		
		var tween = create_tween()
		tween.set_parallel()
		tween.tween_property(from_child,"position",to_child.position,0.15)
		tween.tween_property(from_child,"scale",to_child.scale,0.15)
		tween.tween_property(from_child,"z_index",to_child.z_index,0.15)
		
		
		if i == 2:
			tween.finished.connect(func(): anims_done.emit())
		
		
		queued_anim = false
		i += 1

func _on_anims_done():
	anims_running = false
	if queued_anim: cycle_display()
