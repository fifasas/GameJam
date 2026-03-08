# BossDeathEffect.gd
extends AnimatedSprite2D

func _ready():
	play("death") # Název tvé animace smrti
	animation_finished.connect(_on_animation_finished)

func _on_animation_finished():
	queue_free() # Smaže samo sebe po dohrání animace
