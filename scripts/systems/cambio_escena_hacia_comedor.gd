extends Area2D

@onready var game_state = get_tree().get_root().get_node("GameState")  # Accede al GameState

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

# Detecta cuando Ana entra en la colisión de la puerta
func _on_body_entered(body):
	if body.name == "Ana":
		# Siempre manda a Ana al comedor
		game_state.load_level("res://scenes/levels/NivelComedor.tscn")  # Carga la oficina principal
		
		# Establece el punto de aparición de Ana dependiendo de la puerta
		if name == "CambioEscena_Oficina_Comedor":  # Si viene de la oficina del jefe
			game_state.spawn_name = "SpawnOficina-Comedor"
		elif name == "CambioEscena_SalaConserje_Comedor":  # Si viene del comedor
			game_state.spawn_name = "SpawnSalaConserje-Comedor"
		elif name == "CambioEscena_SalaVigilancia_Comedor":  # Si viene de la sala de igilancia
			game_state.spawn_name = "SpawnSalaVigilancia-Comedor"
