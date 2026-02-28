extends RichTextLabel

@onready var start_pos: Vector2 = position

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.show_player_notification.connect(_on_show_player_notification)
	hide()

func _on_show_player_notification(ntext: String):
	show_notification(ntext)

func show_notification(notification_text: String):
	show()
	text = notification_text
	modulate = Color(Color.WHITE,0.1)
	position.y = start_pos.y + 12
	
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(self,"modulate",Color.WHITE,0.4)
	tween.tween_property(self,"position:y",start_pos.y,0.4)
	tween.tween_interval(2)
	tween.tween_property(self,"modulate",Color(Color.WHITE,0.1),0.1)
	await tween.finished
	hide()
