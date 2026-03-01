extends Area2D

@export var zone_floor_tilemap: TileMapLayer

func _ready():
	#GlobalVarsTester.zone_ground_tilelayer_arr.append(zone_floor_tilemap)
	GlobalVars.zone_ground_tilelayer_arr.append(zone_floor_tilemap)

func _on_body_entered(body):
	if body.name == "Player":
		SignalBus.entered_new_zone.emit(zone_floor_tilemap)
