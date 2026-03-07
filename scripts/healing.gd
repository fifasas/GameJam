extends Area2D

# Kolik HP má tento předmět doplnit (můžeš měnit v Inspektoru)
@export var heal_amount: int = 20

func _on_body_entered(body: Node2D) -> void:
	# Zkontrolujeme, zda to, co do předmětu narazilo, je hráč
	# a zda má metodu "heal" (kterou ve svém kódu máš)
	if body.has_method("heal"):
		# Pokud je hráč už plně vyhealovaný, volitelně můžeš 
		# přidat podmínku, aby se předmět nespotřeboval:
		# if body.current_hp < body.max_hp:
		
		body.heal(heal_amount)
		
		# Předmět zmizí ze světa
		queue_free()
