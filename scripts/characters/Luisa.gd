extends CharacterBody2D

@onready var interact: Area2D = $Interact
@onready var gs: Node = get_tree().root.get_node("GameState")

func _ready() -> void:
	# Conectar la señal de interacción
	if interact and interact.has_signal("interact"):
		interact.connect("interact", Callable(self, "_on_interacted"))
	else:
		push_warning("El nodo $Interact no tiene el signal 'interact'. ¿Tiene asignado Interact.gd?")

func _on_interacted(_player: Node) -> void:
	# Bloquear si ya hay un diálogo activo
	if gs.is_dialog_active:
		return

	# Verificar si la misión "Busca a Luisa" está activa
	if gs.quest.is_current("find_luisa"):
		gs.play_timeline("DialogoLuisaIntroduccion", Callable(self, "_on_dialogue_end"))
	else:
		gs.play_timeline("DialogoLuisaGenerico", Callable(self, "_on_dialogue_end"))

	# Bloquear movimiento e interacción de Ana mientras el diálogo está activo
	gs.set_interaction_enabled(false)
	gs.set_ana_movement(false)

func _on_dialogue_end() -> void:
	# Restaurar interacción y movimiento de Ana
	gs.set_interaction_enabled(true)
	gs.set_ana_movement(true)
