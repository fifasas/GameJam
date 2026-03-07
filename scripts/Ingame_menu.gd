extends Control

@onready var resume_button: Button = $ButtonsCard/ButtonsPadding/ButtonsColumn/ResumeButton

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_menu"):
		get_viewport().set_input_as_handled()
		if get_tree().paused:
			_resume_game()
		else:
			_pause_game()

func _pause_game() -> void:
	show()
	get_tree().paused = true
	resume_button.grab_focus()

func _resume_game() -> void:
	get_tree().paused = false
	hide()

func _on_resume_button_pressed() -> void:
	_resume_game()

func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Menu.tscn")
