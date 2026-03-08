extends Control

const CLICK_SOUND: AudioStream = preload("res://assets/Sounds/Klik_1.mp3")
const CLICK_DELAY: float = 0.12

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
	await _play_click_feedback()
	_resume_game()

func _on_quit_button_pressed() -> void:
	await _play_click_feedback()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Menu.tscn")

func _play_click_feedback() -> void:
	var click_player: AudioStreamPlayer = AudioStreamPlayer.new()
	click_player.stream = CLICK_SOUND
	click_player.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(click_player)
	click_player.finished.connect(click_player.queue_free)
	click_player.play()
	await get_tree().create_timer(CLICK_DELAY).timeout
