extends Control

const CLICK_SOUND: AudioStream = preload("res://assets/Sounds/Klik_1.mp3")
const CLICK_DELAY: float = 0.12

func _play_click_feedback() -> void:
	var click_player: AudioStreamPlayer = AudioStreamPlayer.new()
	click_player.stream = CLICK_SOUND
	click_player.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(click_player)
	click_player.finished.connect(click_player.queue_free)
	click_player.play()
	await get_tree().create_timer(CLICK_DELAY).timeout

func _on_start_button_pressed() -> void:
	await _play_click_feedback()
	get_tree().change_scene_to_file("res://living_room.tscn")

func _on_options_button_pressed() -> void:
	await _play_click_feedback()
	get_tree().change_scene_to_file("res://options.tscn")

func _on_quit_button_pressed() -> void:
	await _play_click_feedback()
	get_tree().quit()
