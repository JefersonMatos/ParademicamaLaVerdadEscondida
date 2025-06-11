extends Control

@onready var dialogic := $Dialogic

func _ready():
	# Inicia el timeline principal
	dialogic.start("IntroDialog")

	# Conecta el signal para cuando termine el timeline
	dialogic.timeline_ended.connect(_on_dialogo_terminado)

func _on_dialogo_terminado():
	# Al terminar el timeline, iniciamos el juego
	var game_state = get_tree().root.get_node("GameState")
	game_state.activar_modo_juego()
	game_state.spawn_name = "SpawnAna"
	game_state.load_level("res://scenes/levels/NivelOficina.tscn")
