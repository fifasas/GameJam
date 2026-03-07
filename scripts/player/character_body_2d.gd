extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -600.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Přidání gravitace
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Skok
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Získání směru pohybu
	var direction := Input.get_axis("left", "right")
	
	# Otočení postavy podle směru
	if direction > 0:
		animated_sprite_2d.flip_h = true # Opraveno: většinou je vpravo false
	elif direction < 0:
		animated_sprite_2d.flip_h = false
	
	# Přepínání animací
	if is_on_floor():
		if direction == 0:
			animated_sprite_2d.play("Idle")
		else:
			animated_sprite_2d.play("walk")
	else: # Tady byla ta chyba v odsazení (byla tu mezera navíc)
		animated_sprite_2d.play("jump") # Opraven překlep z .plya na .play
	
	# Výpočet rychlosti
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
