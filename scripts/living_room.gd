extends Node2D

const LEVEL_1_PATH := "res://first_level.tscn"
const LEVEL_2_PATH := "res://level_2.tscn"
const LEVEL_2_UNLOCKED_KEY := &"level_2_unlocked"

var current_target_path := ""
var current_target_label := ""

@onready var prompt_label: Label = $HUD/Screen2/Prompt
@onready var level_1_label: Label = $Level1Zone/Label
@onready var level_2_zone: Area2D = $Level2Zone
@onready var level_2_label: Label = $Level2Zone/Label
@onready var level_2_icon: Sprite2D = $Level1Zone/Klubko

func _ready() -> void:
	level_1_label.hide()
	level_2_label.hide()
	_update_level_2_unlock_state()
	_update_prompt()

func _unhandled_input(event: InputEvent) -> void:
	if current_target_path == "":
		return
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		get_tree().change_scene_to_file(current_target_path)

func _on_level_1_zone_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	level_1_label.show()
	_set_current_target(LEVEL_1_PATH, "The Mouse")

func _on_level_1_zone_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	level_1_label.hide()
	if current_target_path == LEVEL_1_PATH:
		_clear_current_target()

func _on_level_2_zone_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or not _is_level_2_unlocked():
		return
	level_2_label.show()
	_set_current_target(LEVEL_2_PATH, "The Yarn")

func _on_level_2_zone_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	level_2_label.hide()
	if current_target_path == LEVEL_2_PATH:
		_clear_current_target()

func _set_current_target(path: String, label_text: String) -> void:
	current_target_path = path
	current_target_label = label_text
	_update_prompt()

func _clear_current_target() -> void:
	current_target_path = ""
	current_target_label = ""
	_update_prompt()

func _update_prompt() -> void:
	prompt_label.visible = current_target_path != ""
	if prompt_label.visible:
		prompt_label.text = "Press E to start %s" % current_target_label

func _update_level_2_unlock_state() -> void:
	var unlocked := _is_level_2_unlocked()
	level_2_zone.monitoring = unlocked
	level_2_zone.monitorable = unlocked
	level_2_icon.visible = unlocked
	if not unlocked:
		level_2_label.hide()
		if current_target_path == LEVEL_2_PATH:
			_clear_current_target()

func _is_level_2_unlocked() -> bool:
	return get_tree().has_meta(LEVEL_2_UNLOCKED_KEY) and bool(get_tree().get_meta(LEVEL_2_UNLOCKED_KEY))
