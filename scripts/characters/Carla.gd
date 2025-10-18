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

	if gs.quest and gs.quest.is_current("find_carla"):
		gs.play_timeline("Carla-find_carla", Callable(self, "_on_dialogue_end_find_carla"))
	else:
		gs.play_timeline("Carla-generico", Callable(self, "_on_dialogue_end_generico"))

	gs.set_interaction_enabled(false)
	gs.set_ana_movement(false)

func _on_dialogue_end_find_carla() -> void:
	if gs.quest and gs.quest.is_current("find_carla"):
		gs.quest.complete("find_carla")

	# Pide al GameState que recargue la escena con transición.
	if gs.has_method("reload_current_scene_with_transition"):
		gs.reload_current_scene_with_transition()

	# El código para restaurar interacción se ejecutará, pero la recarga lo interrumpirá.
	gs.set_interaction_enabled(true)
	gs.set_ana_movement(true)

func _on_dialogue_end_generico() -> void:
	gs.set_interaction_enabled(true)
	gs.set_ana_movement(true)
