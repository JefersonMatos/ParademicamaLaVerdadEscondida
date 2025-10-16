extends Node2D

@onready var interact: Area2D = $Interact
@onready var gs: Node = get_tree().root.get_node("GameState")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite_Luisa

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

	# La lógica de interacción ya es correcta y no necesita cambios.
	if gs.quest and gs.quest.is_current("find_luisa"):
		gs.play_timeline("DialogoLuisaIntroduccion", Callable(self, "_on_dialogue_end"))
	else:
		gs.play_timeline("DialogoLuisaGenerico", Callable(self, "_on_dialogue_end"))

	gs.set_interaction_enabled(false)
	gs.set_ana_movement(false)

# Callback para cuando el diálogo termina
func _on_dialogue_end() -> void:
	# Si la misión "Busca a Luisa" está activa, completarla.
	if gs.quest and gs.quest.is_current("find_luisa"):
		# <-- CORREGIDO: Llamada directa a la función 'complete'.
		gs.quest.complete("find_luisa")
		
		# <-- CORREGIDO: Llamada directa a la función 'add_objective'.
		gs.quest.add_objective("explore_office", "Explora las instalaciones y habla con los trabajadores")

	# Restaurar interacción y movimiento de Ana después del diálogo
	gs.set_interaction_enabled(true)
	gs.set_ana_movement(true)
