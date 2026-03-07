extends Node2D

const NEXT_LEVEL_PATH := "res://level_2.tscn"

var boss_defeated := false
var player_in_exit_zone := false

@onready var exit_prompt: Label = $HUD/Screen/ExitPrompt

func _ready() -> void:
	_update_exit_prompt()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and boss_defeated and player_in_exit_zone:
		get_viewport().set_input_as_handled()
		get_tree().change_scene_to_file(NEXT_LEVEL_PATH)

func _on_mouse_boss_defeated() -> void:
	boss_defeated = true
	_update_exit_prompt()

func _on_exit_zone_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	player_in_exit_zone = true
	_update_exit_prompt()

func _on_exit_zone_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	player_in_exit_zone = false
	_update_exit_prompt()

func _update_exit_prompt() -> void:
	exit_prompt.visible = boss_defeated and player_in_exit_zone
