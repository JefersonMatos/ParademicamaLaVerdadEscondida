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
		"go_to_janitor":
			dialogue_timeline = "Conserje-go_to_janitor" # El diálogo donde Ana explica la orden
			callback_function = Callable(self, "_on_dialogue_end_go_to_janitor") # Callback que avanza la misión

	# Solo reproduce si se encontró un diálogo relevante.
	if not dialogue_timeline.is_empty():
		gs.play_timeline(dialogue_timeline, callback_function) # Usa el callback asignado
		gs.set_interaction_enabled(false)
		gs.set_ana_movement(false)

# Callback específico para M12 -> M13
func _on_dialogue_end_go_to_janitor() -> void:
	# El QuestManager activará automáticamente M13 ('search_proof_3').
	if gs.quest and gs.quest.is_current("go_to_janitor"):
		gs.quest.complete("go_to_janitor")

	# Restaura control.
	gs.set_interaction_enabled(true)
	gs.set_ana_movement(true)

# Callback genérico para diálogos que NO avanzan la misión.
func _on_dialogue_end_generico() -> void:
	gs.set_interaction_enabled(true)
	gs.set_ana_movement(true)
