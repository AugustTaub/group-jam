extends Node

signal player_move()
signal stop_player_move #stops player from moving
signal create_companion_by_id(type : int)
signal create_companion_by_name(type : String)
signal teleport_player(pos : Vector2)

signal game_started
signal end_game
signal open_thanks_window
signal play_audio(audio_name: String)

signal switch_companion_pressed(new_active_index:int)
signal added_companion(add_index:int,companion_type: int)
signal removed_companion(remove_index:int)

signal parried_bullet

signal show_player_notification(text: String)

signal entered_new_zone(zone_floor_tilemap: TileMapLayer)
