extends Control

func _ready():
	$StartButton.pressed.connect(_on_start_pressed)
	$ExitButton.pressed.connect(_on_exit_pressed)

func _on_start_pressed():
	# Instanciar GameState solo si no existe
	if not get_tree().root.has_node("GameState"):
		var game_state = load("res://scenes/characters/GameState.tscn").instantiate()
		game_state.name = "GameState"
		get_tree().root.add_child(game_state)

	# Cambiar a la pantalla de carga
	get_tree().change_scene_to_file("res://scenes/ui/LoadingScreen.tscn")

func _on_exit_pressed():
	get_tree().quit()
