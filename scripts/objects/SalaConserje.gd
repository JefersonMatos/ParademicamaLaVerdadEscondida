extends Node2D

@onready var interact_area: Area2D = $Interact_Cajas # Referencia al Area2D de interacción
@onready var gs: Node = get_tree().root.get_node("GameState")

func _ready() -> void:
	# Conectar a la señal 'interact' emitida por el script del Area2D
	if interact_area and interact_area.has_signal("interact"):
		interact_area.connect("interact", Callable(self, "_on_interacted"))
	else:
		push_warning("El nodo $Interact_Cajas no tiene el signal 'interact'. ¿Tiene asignado Interact.gd?")

func _on_interacted(_player: Node) -> void:
	# No hacer nada si ya hay un diálogo activo
	if gs.is_dialog_active:
		return

	var dialogue_timeline = ""
	var callback_function = Callable() # Variable para el callback

	# Verificar si la misión actual es M13: search_proof_3
	if gs.quest and gs.quest.is_current("search_proof_3"):
		# Misión activa: Reproducir diálogo de descubrimiento (M13 -> M14)
		dialogue_timeline = "Ana-search_proof_3"
		callback_function = Callable(self, "_on_dialogue_end_search")
	else:
		# Misión NO activa: Reproducir diálogo genérico
		dialogue_timeline = "Caja-generico"
		callback_function = Callable(self, "_on_dialogue_end_generico")

	# Reproducir el diálogo seleccionado y bloquear al jugador
	gs.play_timeline(dialogue_timeline, callback_function)
	gs.set_interaction_enabled(false)
	gs.set_ana_movement(false)

# Callback para cuando el diálogo de M13 finaliza (M13 -> M14)
func _on_dialogue_end_search() -> void:
	# Completar la misión actual (M13: search_proof_3).
	# El QuestManager activará automáticamente M14 ('talk_to_miguel').
	if gs.quest and gs.quest.is_current("search_proof_3"):
		gs.quest.complete("search_proof_3")
		
	# Restaurar control del jugador
	gs.set_interaction_enabled(true)
	gs.set_ana_movement(true)
	
# Callback genérico para cuando se reproduce el diálogo Caja-generico
func _on_dialogue_end_generico() -> void:
	# Simplemente restaurar control del jugador
	gs.set_interaction_enabled(true)
	gs.set_ana_movement(true)
