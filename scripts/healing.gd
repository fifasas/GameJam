extends Area2D

signal collected

@export var heal_amount: int = 20
@onready var fish_audio: AudioStreamPlayer2D = $FishAudio

var is_collected := false

func _ready() -> void:
	if fish_audio.stream != null:
		fish_audio.play()

func _on_body_entered(body: Node2D) -> void:
	_try_collect(body)

func _on_area_entered(area: Area2D) -> void:
	_try_collect(area)

func _on_fish_audio_finished() -> void:
	if is_queued_for_deletion():
		return
	if fish_audio.stream != null:
		fish_audio.play()

func _try_collect(overlap: Node) -> void:
	if is_collected:
		return

	var heal_target := _find_heal_target(overlap)
	if heal_target == null:
		return

	is_collected = true
	heal_target.heal(heal_amount)
	collected.emit()
	queue_free()

func _find_heal_target(overlap: Node) -> Node:
	if overlap.has_method("heal"):
		return overlap

	var parent := overlap.get_parent()
	if parent != null and parent.has_method("heal"):
		return parent

	return null
