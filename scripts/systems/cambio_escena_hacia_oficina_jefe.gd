extends Area2D

@onready var puerta := $"../Puerta"
@onready var anim := puerta.get_node("SpritePuerta")
@onready var sonido_abrir := puerta.get_node("SonidoAbrir")

var puerta_abierta := false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "Ana":
		var game_state = get_tree().get_root().get_node("GameState")
		game_state.spawn_name = "SpawnOficina-OficinaJefe"
		game_state.load_level("res://scenes/levels/NivelOficinaJefe.tscn")
