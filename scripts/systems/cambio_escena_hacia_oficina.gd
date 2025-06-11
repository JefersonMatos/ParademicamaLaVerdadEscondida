extends Area2D

@onready var game_state = get_tree().get_root().get_node("GameState")  # Accede al GameState

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "Ana":
		
		# Siempre manda a Ana a la oficina principal
		game_state.load_level("res://scenes/levels/NivelOficina.tscn")  # Carga la oficina principal
		
		# Establece el punto de aparición de Ana dependiendo de la puerta
		if name == "CambioEscena_OficinaJefe_Oficina":  # Si viene de la oficina del jefe
			game_state.spawn_name = "SpawnOficinaJefe-Oficina"
		elif name == "CambioEscena_Comedor_Oficina":  # Si viene del comedor
			game_state.spawn_name = "SpawnComedor-Oficina"
		elif name == "CambioEscena_SalaJuntas_Oficina":  # Si viene de la Sala de Juntas
			game_state.spawn_name = "SpawnSalaJuntas-Oficina"
		elif name == "CambioEscena_EstudioGrabacion_Oficina":  # Si viene del Estudio de Grabacion
			game_state.spawn_name = "SpawnEstudioGrabacion-Oficina"
