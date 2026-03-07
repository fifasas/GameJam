extends Node2D

const HIT_FLASH_DURATION := 0.12
const HIT_FLASH_COLOR := Color(1.0, 0.85, 0.85, 1.0)

@export var standing_rotation_degrees := -84.0
@export var fallen_rotation_degrees := 0.0
@export var fallen_offset := Vector2(140.0, 120.0)
@export var fall_duration := 0.45

var has_fallen := false
var hit_flash_id := 0
var starting_position := Vector2.ZERO

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var standing_collision: CollisionShape2D = $StandingBody/CollisionShape2D
@onready var bridge_collision: CollisionShape2D = $BridgeBody/CollisionShape2D
@onready var hit_collision: CollisionShape2D = $HitArea/CollisionShape2D

func _ready() -> void:
	starting_position = position
	rotation_degrees = standing_rotation_degrees
	bridge_collision.disabled = true

func take_damage(amount: int) -> void:
	if amount <= 0 or has_fallen:
		return

	has_fallen = true
	standing_collision.disabled = true
	hit_collision.disabled = true
	_flash_hit()

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "rotation_degrees", fallen_rotation_degrees, fall_duration)
	tween.parallel().tween_property(self, "position", starting_position + fallen_offset, fall_duration)
	await tween.finished

	bridge_collision.disabled = false
	sprite_2d.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _flash_hit() -> void:
	hit_flash_id += 1
	var flash_id := hit_flash_id
	sprite_2d.modulate = HIT_FLASH_COLOR
	_reset_flash_after_delay(flash_id)

func _reset_flash_after_delay(flash_id: int) -> void:
	await get_tree().create_timer(HIT_FLASH_DURATION).timeout
	if flash_id != hit_flash_id or not is_instance_valid(sprite_2d):
		return
	sprite_2d.modulate = Color(1.0, 1.0, 1.0, 1.0)
