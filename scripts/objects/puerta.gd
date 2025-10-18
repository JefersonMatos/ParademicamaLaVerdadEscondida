extends Area2D

@onready var gs: Node = get_tree().root.get_node("GameState")
@onready var anim := $SpritePuerta
@onready var sonido_abrir := $SonidoAbrir

var is_locked: bool = false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

	if gs and gs.quest and gs.quest.has_signal("objective_changed"):
		gs.quest.connect("objective_changed", _on_objective_changed)
	
	var current_quest_id = gs.quest.current_id() if gs and gs.quest else ""
	_update_door_state(current_quest_id)

func _on_objective_changed(id: String, _text: String, _index: int, _total: int) -> void:
	_update_door_state(id)

func _update_door_state(quest_id: String) -> void:
	is_locked = quest_id in ["go_to_janitor", "search_proof_3", "talk_to_miguel"]
	
	# Si la puerta acaba de bloquearse, asegúrate de que esté visualmente cerrada
	if is_locked:
		anim.play("cerrar")

func _on_body_entered(body):
	if body.name == "Ana":
		if not is_locked:
			anim.play("abrir")
			sonido_abrir.play()
		# Si está bloqueada, no hace nada al entrar

func _on_body_exited(body):
	if body.name == "Ana":
		# 🟡 CAMBIO CLAVE: Solo cerrar si NO está bloqueada
		if not is_locked:
			anim.play("cerrar")
		# Si está bloqueada, la animación ya debería estar en "cerrar"
		# y no hacemos nada al salir.
