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
	# Bloquear si ya hay un diálogo activo
	if gs.is_dialog_active:
		return

	var dialogue_timeline = "" # Inicializamos sin diálogo
	var current_quest = ""
	if gs.quest.has_method("current_id"):
		current_quest = gs.quest.current_id() # Lógica para determinar el diálogo basado en la misión actual

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
		_:
			pass # Si la misión no coincide, 'dialogue_timeline' se queda vacío.

	# Si hay diálogo, lo reproducimos y bloqueamos el juego
	gs.play_timeline(dialogue_timeline, Callable(self, "_on_dialogue_end"))

	# Bloquear movimiento e interacción de Ana mientras el diálogo está activo
	gs.set_interaction_enabled(false)
	gs.set_ana_movement(false)

# Callback para cuando el diálogo termina
func _on_dialogue_end() -> void:
	# Restaurar interacción y movimiento de Ana después del diálogo
	gs.set_interaction_enabled(true)
	gs.set_ana_movement(true)
