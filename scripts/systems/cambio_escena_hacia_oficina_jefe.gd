extends Area2D

@onready var gs := get_tree().root.get_node("GameState")

@export var target_scene_path: String = "res://scenes/levels/NivelOficinaJefe.tscn"
@export var spawn_name_on_arrive: String = "SpawnOficina-OficinaJefe"
@export var complete_objective_id: String = "go_boss_office"

var _triggered := false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if _triggered: 
		return
	if body.name != "Ana":
		return
	_triggered = true

	# (Opcional) animar/sonar la puerta si existen esos nodos
	if has_node("../Puerta"):
		var puerta := $"../Puerta"
		if puerta.has_node("SpritePuerta"):
			var anim = puerta.get_node("SpritePuerta")
			if "play" in anim: anim.play("abrir")
		if puerta.has_node("SonidoAbrir"):
			puerta.get_node("SonidoAbrir").play()

	# Marca el objetivo "ir a la oficina del jefe" como completado
	if gs and gs.has_method("quest_complete"):
		gs.quest_complete(complete_objective_id)

	# Cambia de escena con el spawn adecuado
	gs.spawn_name = spawn_name_on_arrive
	gs.load_level(target_scene_path)
