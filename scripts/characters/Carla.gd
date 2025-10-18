extends Node2D

@onready var interact: Area2D = $Interact
@onready var gs: Node = get_tree().root.get_node("GameState")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite_Carla

func _ready() -> void:
	if animated_sprite:
		animated_sprite.play("idle_down")
	if interact and interact.has_signal("interact"):
		interact.connect("interact", Callable(self, "_on_interacted"))

func _on_interacted(_player: Node) -> void:
	if gs.is_dialog_active: return

	var dialogue_timeline = "Carla-generico" # Default
	var callback_function = Callable(self, "_on_dialogue_end_generico") # Default

	# Check current mission
	if gs.quest:
		if gs.quest.is_current("find_carla"): # M10
			dialogue_timeline = "Carla-find_carla"
			callback_function = Callable(self, "_on_dialogue_end_find_carla")

		elif gs.quest.is_current("convince_carla"):
			dialogue_timeline = "Carla-convince_carla" # Crea este diálogo
			callback_function = Callable(self, "_on_dialogue_end_convince_carla") # Nuevo callback

	# Play dialogue if found (including generic)
	gs.play_timeline(dialogue_timeline, callback_function)
	gs.set_interaction_enabled(false)
	gs.set_ana_movement(false)

# Callback para M10 -> M11
func _on_dialogue_end_find_carla() -> void:
	if gs.quest and gs.quest.is_current("find_carla"):
		gs.quest.complete("find_carla")

	# Pide recarga con transición negra
	if gs.has_method("reload_current_scene_with_transition"):
		gs.reload_current_scene_with_transition()

	# Estas líneas probablemente no se ejecuten debido a la recarga
	gs.set_interaction_enabled(true)
	gs.set_ana_movement(true)

# 🟢 Callback para M20 -> M21
func _on_dialogue_end_convince_carla() -> void:
	# Completa M20. QuestManager activará M21 ('the_27_february').
	if gs.quest and gs.quest.is_current("convince_carla"):
		gs.quest.complete("convince_carla")
	gs.set_interaction_enabled(true)
	gs.set_ana_movement(true)

# Callback genérico
func _on_dialogue_end_generico() -> void:
	gs.set_interaction_enabled(true)
	gs.set_ana_movement(true)
