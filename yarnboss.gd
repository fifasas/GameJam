extends CharacterBody2D

const SPEED = 400.0

func _ready():
	# Nastavení počátečního pohybu
	velocity = Vector2(1, 1).normalized() * SPEED
	
	# Maska říká: "Do těchto vrstev chci narážet"
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, true)

func _physics_process(delta: float) -> void:
	# move_and_collide vrací info o nárazu. 
	# Velocity násobíme delta, protože tahle funkce nepočítá s časem automaticky.
	var collision = move_and_collide(velocity * delta)

	if collision:
		# Pokud došlo ke kolizi, odrazíme velocity podle normály (směru stěny)
		velocity = velocity.bounce(collision.get_normal())
		
		# DŮLEŽITÉ: Zbytek pohybu po odrazu. 
		# Aby boss v tom samém snímku "odletěl" od stěny a nezůstal v ní viset.
		move_and_collide(velocity * delta)
		
		# Ujistíme se, že rychlost je stále stejná
		velocity = velocity.normalized() * SPEED
