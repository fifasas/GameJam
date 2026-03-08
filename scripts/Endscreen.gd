extends Control

const LEVEL_RESTART_PATH := "res://level_3.tscn"
const LOBBY_PATH := "res://living_room.tscn"
const HEALTH_META_KEY := &"player_saved_health"

func _ready() -> void:
	get_tree().paused = false
	_clear_saved_health()

func _on_restart_pressed() -> void:
	_clear_saved_health()
	get_tree().change_scene_to_file(LEVEL_RESTART_PATH)

func _on_lobby_pressed() -> void:
	_clear_saved_health()
	get_tree().change_scene_to_file(LOBBY_PATH)

func _on_quit_pressed() -> void:
	_clear_saved_health()
	get_tree().quit()

func _clear_saved_health() -> void:
	if get_tree().has_meta(HEALTH_META_KEY):
		get_tree().remove_meta(HEALTH_META_KEY)
