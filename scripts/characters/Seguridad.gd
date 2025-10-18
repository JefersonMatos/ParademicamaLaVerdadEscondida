# Seguridad.gd (Corregido)
extends Node2D

@onready var interact: Area2D = $Interact
@onready var gs: Node = get_tree().root.get_node("GameState")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite_Seguridad

func _ready() -> void:
	if animated_sprite:
		animated_sprite.play("idle_up")
	
	if interact and interact.has_signal("interact"):
		interact.connect("interact", Callable(self, "_on_interacted"))
	else:
		push_warning("El nodo $Interact no tiene el signal 'interact'. ¿Tiene asignado Interact.gd?")

func _on_interacted(_player: Node) -> void:
	if gs.is_dialog_active:
		return

	var dialogue_timeline = "Seguridad-generico" # Default
	var callback_function = Callable(self, "_on_dialogue_end_generico") # Default

	# Check current mission
	if gs.quest:
		if gs.quest.is_current("deliver_mysterious_envelope"): # M6
			dialogue_timeline = "Seguridad-deliver_mysterious_envelope"
			callback_function = Callable(self, "_on_dialogue_end_deliver_envelope")
		elif gs.quest.is_current("boss_needs_sergio"): # M16
			dialogue_timeline = "Seguridad-boss_needs_sergio"
			callback_function = Callable(self, "_on_dialogue_end_boss_needs_sergio")

	# Play dialogue if found
	if not dialogue_timeline.is_empty():
		gs.play_timeline(dialogue_timeline, callback_function)
		gs.set_interaction_enabled(false)
		gs.set_ana_movement(false)

# Callback para M6 -> M7
func _on_dialogue_end_deliver_envelope() -> void:
	if gs.quest and gs.quest.is_current("deliver_mysterious_envelope"):
		gs.quest.complete("deliver_mysterious_envelope")
	gs.set_interaction_enabled(true)
	gs.set_ana_movement(true)

# Callback para M16 -> M17 ('extract_proof_4')
func _on_dialogue_end_boss_needs_sergio() -> void:
	if gs.has_method("reload_current_scene_with_transition"):
		gs.reload_current_scene_with_transition()
	
	# Completa M16. El QuestManager (al recibir esto) activará M17 ('extract_proof_4').
	if gs.quest and gs.quest.is_current("boss_needs_sergio"):
		gs.quest.complete("boss_needs_sergio")

	# El código para restaurar interacción se ejecutará, 
	# pero la recarga de escena lo interrumpirá 
	gs.set_interaction_enabled(true)
	gs.set_ana_movement(true)

# Callback genérico
func _on_dialogue_end_generico() -> void:
	gs.set_interaction_enabled(true)
	gs.set_ana_movement(true)
