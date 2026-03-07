extends Control

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Menu.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_menu"):
		_on_back_button_pressed()
