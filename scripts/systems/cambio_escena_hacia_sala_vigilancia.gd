extends Area2D

@onready var game_state = get_tree().get_root().get_node("GameState")  # Accede al GameState

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

# Detecta cuando Ana entra en la colisión de la puerta
func _on_body_entered(body):
	if body.name == "Ana": 
		game_state.spawn_name = "SpawnComedor-SalaVigilancia"  # Ajusta el punto de spawn en la sala del conserje
		game_state.load_level("res://scenes/levels/NivelSalaVigilancia.tscn")  # Carga la escena de la sala del conserje
