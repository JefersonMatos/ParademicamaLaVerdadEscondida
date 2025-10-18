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

	if gs.quest and gs.quest.is_current("find_luisa"):
		gs.play_timeline("DialogoLuisaIntroduccion", Callable(self, "_on_dialogue_end"))
	else:
		gs.play_timeline("DialogoLuisaGenerico", Callable(self, "_on_dialogue_end"))

	gs.set_interaction_enabled(false)
	gs.set_ana_movement(false)

# 🟡 CAMBIADO: La función ahora solo COMPLETA la misión.
func _on_dialogue_end() -> void:
	# Si la misión "Busca a Luisa" está activa, la completa.
	# El QuestManager se encargará automáticamente de activar la siguiente.
	if gs.quest and gs.quest.is_current("find_luisa"):
		gs.quest.complete("find_luisa")

	# Restaurar interacción y movimiento de Ana después del diálogo
	gs.set_interaction_enabled(true)
	gs.set_ana_movement(true)
