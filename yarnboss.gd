extends CharacterBody2D

const SPEED = 400.0

func _ready():
	velocity = Vector2(1, 1).normalized() * SPEED
	# Maska 1 = Hráč, Maska 2 = Zdi (ujisti se, že to tak máš v editoru)
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, true)

func _physics_process(delta: float) -> void:
	# move_and_collide vrací info o nárazu (včetně nárazu do hráče)
	var collision = move_and_collide(velocity * delta)

	if collision:
		# Odrazí se od čehokoliv, co má kolizi (zeď i hráč)
		velocity = velocity.bounce(collision.get_normal())
		velocity = velocity.normalized() * SPEED

# Tato funkce se zavolá z hráčova skriptu při útoku
func take_damage(amount: int):
	# Najdeme směr od hráče k bossovi
	var player = get_tree().get_first_node_in_group("player") # Hráč musí být ve skupině "player"
	if player:
		var direction_away = (global_position - player.global_position).normalized()
		velocity = direction_away * SPEED
	
	# Tady můžeš ubrat bossovi HP
