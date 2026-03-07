extends Area2D

# Cesta k nové scéně, kterou chceš načíst
@export_file("*.tscn") var cilova_scena: String

var hrac_v_dosahu = false


# Funkce, která se spustí, když hráč vejde do Area2D
func _on_body_entered(body):
	if body.is_in_group("hrac"): # Ujisti se, že tvůj hráč je ve skupině "hrac"
		hrac_v_dosahu = true
		$Sipka.show()

# Funkce, která se spustí, když hráč odejde
func _on_body_exited(body):
	if body.is_in_group("hrac"):
		hrac_v_dosahu = false
		$Sipka.hide()

func _process(_delta):
	# Pokud je hráč blízko a zmáčkne E
	if hrac_v_dosahu and Input.is_action_just_pressed("interakce"):
		zmen_scenu()

func zmen_scenu():
	if cilova_scena == "":
		print("Chyba: Není nastavena cílová scéna!")
		return
	get_tree().change_scene_to_file(cilova_scena)
