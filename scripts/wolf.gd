extends CharacterBody2D

signal boss_defeated

const WALK_SPEED := 70.0
const RUN_SPEED := 155.0
const DETECTION_RANGE := 520.0
const MAX_VERTICAL_TRACKING := 140.0
const ATTACK_RANGE := 95.0
const ATTACK_DAMAGE := 20
const ATTACK_COOLDOWN := 1.1
const ATTACK_HIT_DELAY := 0.3
const HOWL_COOLDOWN := 4.0
const PATROL_DISTANCE := 260.0
const HIT_FLASH_DURATION := 0.2
const HIT_FLASH_COLOR := Color(1.0, 0.35, 0.35, 1.0)

enum State {
	IDLE,
	WALK,
	RUN,
	HOWL,
	ATTACK,
}

@export_range(1, 9999, 1) var max_hp: int = 35
@export_range(0, 9999, 1) var current_hp: int = 35

var gravity := 0.0
var spawn_x := 0.0
var patrol_direction := 1
var facing_direction := 1
var state := State.WALK
var hit_flash_id := 0
var player_spotted := false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_hit_timer: Timer = $AttackHitTimer
@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer
@onready var howl_cooldown_timer: Timer = $HowlCooldownTimer

func _ready() -> void:
	gravity = float(ProjectSettings.get_setting("physics/2d/default_gravity"))
	current_hp = clamp(current_hp, 0, max_hp)
	spawn_x = global_position.x
	_update_facing()
	_update_attack_area()
	_update_animation()

func _physics_process(delta: float) -> void:
	if current_hp <= 0:
		return

	if not is_on_floor():
		velocity.y += gravity * delta
	elif velocity.y > 0.0:
		velocity.y = 0.0

	var player_target := _get_player_target()
	var can_track := _can_track_player(player_target)

	if state == State.ATTACK or state == State.HOWL:
		velocity.x = move_toward(velocity.x, 0.0, RUN_SPEED)
	else:
		if can_track:
			_handle_player_tracking(player_target)
		else:
			player_spotted = false
			_handle_patrol()

	move_and_slide()

	if state == State.WALK and is_on_wall():
		patrol_direction *= -1

	_update_facing()
	_update_attack_area()
	_update_animation()

func take_damage(amount: int) -> void:
	if amount <= 0 or current_hp <= 0:
		return

	current_hp = max(current_hp - amount, 0)
	_flash_hit()
	if current_hp == 0:
		boss_defeated.emit()
		queue_free()

func _handle_player_tracking(player_target: CharacterBody2D) -> void:
	var delta_x := player_target.global_position.x - global_position.x
	facing_direction = 1 if delta_x >= 0.0 else -1

	if not player_spotted and howl_cooldown_timer.is_stopped():
		player_spotted = true
		_start_howl()
		return

	player_spotted = true
	var vertical_distance = abs(player_target.global_position.y - global_position.y)
	if abs(delta_x) <= ATTACK_RANGE and vertical_distance <= MAX_VERTICAL_TRACKING:
		if attack_cooldown_timer.is_stopped():
			_start_attack()
		else:
			state = State.IDLE
			velocity.x = 0.0
		return

	state = State.RUN
	velocity.x = sign(delta_x) * RUN_SPEED

func _handle_patrol() -> void:
	if global_position.x <= spawn_x - PATROL_DISTANCE:
		patrol_direction = 1
	elif global_position.x >= spawn_x + PATROL_DISTANCE:
		patrol_direction = -1

	facing_direction = patrol_direction
	state = State.WALK
	velocity.x = patrol_direction * WALK_SPEED

func _start_howl() -> void:
	if state == State.HOWL or state == State.ATTACK:
		return

	state = State.HOWL
	velocity.x = 0.0
	howl_cooldown_timer.start(HOWL_COOLDOWN)
	animated_sprite_2d.play(&"howl")

func _start_attack() -> void:
	if state == State.ATTACK or state == State.HOWL:
		return

	state = State.ATTACK
	velocity.x = 0.0
	attack_cooldown_timer.start(ATTACK_COOLDOWN)
	attack_hit_timer.start(ATTACK_HIT_DELAY)
	animated_sprite_2d.play(&"attack")

func _on_attack_hit_timer_timeout() -> void:
	var hit_targets: Array[Node] = []
	for body in attack_area.get_overlapping_bodies():
		var target := _find_damage_target(body)
		if target == null or target == self or hit_targets.has(target):
			continue

		if target.has_method("damage"):
			target.damage(ATTACK_DAMAGE)
		elif target.has_method("set_health"):
			target.set_health(target.current_hp - ATTACK_DAMAGE)

		hit_targets.append(target)

func _on_animated_sprite_2d_animation_finished() -> void:
	if state == State.ATTACK and animated_sprite_2d.animation == &"attack":
		state = State.IDLE if player_spotted else State.WALK
	elif state == State.HOWL and animated_sprite_2d.animation == &"howl":
		state = State.RUN if player_spotted else State.WALK

	_update_animation()

func _get_player_target() -> CharacterBody2D:
	for node in get_tree().get_nodes_in_group("player"):
		if node is CharacterBody2D and (node.has_method("damage") or node.has_method("set_health")):
			return node
	return null

func _can_track_player(player_target: CharacterBody2D) -> bool:
	if player_target == null or not is_instance_valid(player_target):
		return false
	if player_target.has_method("is_dead") and player_target.is_dead():
		return false

	var delta := player_target.global_position - global_position
	return abs(delta.x) <= DETECTION_RANGE and abs(delta.y) <= MAX_VERTICAL_TRACKING

func _find_damage_target(body: Node) -> Node:
	if body.has_method("damage") or body.has_method("set_health"):
		return body

	var parent := body.get_parent()
	if parent != null and (parent.has_method("damage") or parent.has_method("set_health")):
		return parent

	return null

func _update_attack_area() -> void:
	attack_area.position = Vector2(72.0 * facing_direction, -60.0)

func _update_facing() -> void:
	animated_sprite_2d.flip_h = facing_direction > 0

func _update_animation() -> void:
	match state:
		State.ATTACK:
			if animated_sprite_2d.animation != &"attack":
				animated_sprite_2d.play(&"attack")
		State.HOWL:
			if animated_sprite_2d.animation != &"howl":
				animated_sprite_2d.play(&"howl")
		State.RUN:
			if animated_sprite_2d.animation != &"run":
				animated_sprite_2d.play(&"run")
		State.WALK:
			if animated_sprite_2d.animation != &"walk":
				animated_sprite_2d.play(&"walk")
		_:
			if animated_sprite_2d.animation != &"idle":
				animated_sprite_2d.play(&"idle")

func _flash_hit() -> void:
	hit_flash_id += 1
	var flash_id := hit_flash_id
	animated_sprite_2d.modulate = HIT_FLASH_COLOR
	_reset_flash_after_delay(flash_id)

func _reset_flash_after_delay(flash_id: int) -> void:
	await get_tree().create_timer(HIT_FLASH_DURATION).timeout
	if flash_id != hit_flash_id or not is_instance_valid(animated_sprite_2d):
		return
	animated_sprite_2d.modulate = Color(1.0, 1.0, 1.0, 1.0)
