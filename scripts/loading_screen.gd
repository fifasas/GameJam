extends Control

const DISPLAY_DURATION := 5.0
const MENU_SCENE_PATH := "res://Menu.tscn"

func _ready() -> void:
	await get_tree().create_timer(DISPLAY_DURATION).timeout
	get_tree().change_scene_to_file(MENU_SCENE_PATH)
