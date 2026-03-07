extends Control

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://living_room.tscn")

func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file("res://options.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
