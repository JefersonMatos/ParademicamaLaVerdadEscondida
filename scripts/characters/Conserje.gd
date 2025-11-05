extends Node2D

@onready var interact: Area2D = $Interact
@onready var gs: Node = get_tree().root.get_node("GameState")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite_Conserje 

func _ready() -> void:
	if animated_sprite:
		animated_sprite.play("idle_down") 
	
	if interact and interact.has_signal("interact"):
		interact.connect("interact", Callable(self, "_on_interacted"))
	else:
		push_warning("El nodo $Interact no tiene el signal 'interact'. ¿Tiene asignado Interact.gd?")

func _on_interacted(_player: Node) -> void:
	if gs.is_dialog_active:
		return

	var dialogue_timeline = ""
	var callback_function = Callable(self, "_on_dialogue_end_generico") # Callback por defecto
	var current_quest = gs.quest.current_id() if gs.quest else ""

	# Asigna diálogo y callback según la misión.
	match current_quest:
		# --- MISIONES DE HISTORIA (Avanzan la trama) ---
		"go_to_janitor":
			dialogue_timeline = "Conserje-go_to_janitor"
			callback_function = Callable(self, "_on_dialogue_end_go_to_janitor")
		"talk_to_miguel":
			dialogue_timeline = "Conserje-talk_to_miguel"
			callback_function = Callable(self, "_on_dialogue_end_talk_to_miguel")
		"meet_miguel_again":
			dialogue_timeline = "Conserje-meet_miguel_again"
			callback_function = Callable(self, "_on_dialogue_end_meet_miguel_again")

		# --- MISIONES DE GUÍA (Dan pistas, no avanzan) ---
		"go_boss_office": 
			dialogue_timeline = "Conserje-go_boss_office"
		"talk_boss": 
			dialogue_timeline = "Conserje-talk_boss"
		"find_luisa": 
			dialogue_timeline = "Conserje-find_luisa"
		"explore_office": 
			dialogue_timeline = "Conserje-explore_office"
		"ask_boss": 
			dialogue_timeline = "Conserje-ask_boss"
		"deliver_mysterious_envelope": 
			dialogue_timeline = "Conserje-deliver_mysterious_envelope"
		"report_envelope":
			dialogue_timeline = "Conserje-report_envelope"
		"search_proof_1":
			dialogue_timeline = "Conserje-search_proof_1"
		"report_agenda":
			dialogue_timeline = "Conserje-report_agenda"
		"find_carla":
			dialogue_timeline = "Conserje-find_carla"
		"observe_proof_2":
			dialogue_timeline = "Conserje-observe_proof_2"
		"search_proof_3":
			dialogue_timeline = "Conserje-search_proof_3" # Pista sobre las cajas
		"wait_for_opportunity":
			dialogue_timeline = "Conserje-wait_for_opportunity"
		"ask_boss2":
			dialogue_timeline = "Conserje-ask_boss2"
		"boss_needs_sergio":
			dialogue_timeline = "Conserje-boss_needs_sergio" # Pista sobre dónde está Sergio
		"extract_proof_4":
			dialogue_timeline = "Conserje-extract_proof_4" # Pista de "ten cuidado"
		"convince_carla":
			dialogue_timeline = "Conserje-convince_carla"
		"confrontation":
			dialogue_timeline = "Conserje-confrontation" # Pista final "es hora"
			
		# Si no es ninguna de las anteriores, 'dialogue_timeline' queda vacío
		_:
			pass 

	# Solo reproduce si se encontró un diálogo relevante.
	if not dialogue_timeline.is_empty():
		gs.play_timeline(dialogue_timeline, callback_function)
		gs.set_interaction_enabled(false)
		gs.set_ana_movement(false)

# --- Callbacks (Sin cambios) ---

# Callback específico para M12 -> M13
func _on_dialogue_end_go_to_janitor() -> void:
	if gs.quest and gs.quest.is_current("go_to_janitor"):
		gs.quest.complete("go_to_janitor")
	gs.set_interaction_enabled(true)
	gs.set_ana_movement(true)

# Callback específico para M14 -> M15
func _on_dialogue_end_talk_to_miguel() -> void:
	if gs.quest and gs.quest.is_current("talk_to_miguel"):
		gs.quest.complete("talk_to_miguel")
	gs.set_interaction_enabled(true)
	gs.set_ana_movement(true)

# Callback específico para M19 -> M20
func _on_dialogue_end_meet_miguel_again() -> void:
	if gs.quest and gs.quest.is_current("meet_miguel_again"):
		gs.quest.complete("meet_miguel_again")
	gs.set_interaction_enabled(true)
	gs.set_ana_movement(true)

# Callback genérico para diálogos que NO avanzan la misión.
func _on_dialogue_end_generico() -> void:
	gs.set_interaction_enabled(true)
	gs.set_ana_movement(true)
