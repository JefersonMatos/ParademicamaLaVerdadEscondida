extends CharacterBody2D

@onready var interact: Area2D = $Interact
@onready var gs: Node = get_tree().root.get_node("GameState")

func _ready() -> void:
	# Conecta al signal "interact" desde el script Interact.gd
	if interact and interact.has_signal("interact"):
		interact.connect("interact", Callable(self, "_on_interacted"))
	else:
		push_warning("El nodo $Interact no tiene el signal 'interact'. ¿Tiene asignado Interact.gd?")

func _on_interacted(_player: Node) -> void:
	if gs.is_dialog_active:  # Verifica si ya hay un diálogo en curso
		return  # Si hay un diálogo activo, no permite interactuar

	if gs.jefe_dialogue_completed:
		gs.play_timeline("DialogoJefeOcupado", Callable(self, "_on_dialogue_end"))
	else:
		gs.play_timeline("DialogoJefeBienvenida", Callable(self, "_on_dialogue_end"))

	# Deshabilitar la interacción con Ana durante el diálogo
	gs.set_interaction_enabled(false)
	gs.set_ana_movement(false)  # Deshabilitar movimiento de Ana mientras hay diálogo

# Callback para cuando el diálogo finaliza
func _on_dialogue_end() -> void:
	if gs and gs.has_method("quest_add_next"):
		gs.call("quest_add_next", "find_luisa", "Busca a Luisa")
	if gs and gs.has_method("quest_complete"):
		gs.call("quest_complete", "talk_boss")

	# Establecer que el diálogo con el jefe ha terminado
	gs.jefe_dialogue_completed = true

	# Restaurar la interacción con Ana después del diálogo
	gs.set_interaction_enabled(true)
	gs.set_ana_movement(true)
