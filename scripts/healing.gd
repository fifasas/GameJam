extends Area2D

signal collected

@export var heal_amount: int = 20
@onready var fish_audio: AudioStreamPlayer2D = $FishAudio

func _ready() -> void:
	if fish_audio.stream != null:
		fish_audio.play()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("heal"):
		body.heal(heal_amount)
		collected.emit()
		queue_free()

func _on_fish_audio_finished() -> void:
	if is_queued_for_deletion():
		return
	if fish_audio.stream != null:
		fish_audio.play()
