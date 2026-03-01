extends Area2D

@export var zone_floor_tilemap: TileMapLayer

func _on_body_entered(body):
	if body.name == "Player":
		SignalBus.entered_new_zone.emit(zone_floor_tilemap)
