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

	# Esta lógica ya es correcta: elige el diálogo según la misión.
	if gs.quest and gs.quest.is_current("deliver_mysterious_envelope"):
		gs.play_timeline("Seguridad-deliver_mysterious_envelope", Callable(self, "_on_dialogue_end_deliver_envelope"))
	else:
		gs.play_timeline("Seguridad-generico", Callable(self, "_on_dialogue_end_generico"))

	gs.set_interaction_enabled(false)
	gs.set_ana_movement(false)

# 🟡 CAMBIADO: La función ahora solo COMPLETA la misión.
func _on_dialogue_end_deliver_envelope() -> void:
	# Si la misión actual es la de entregar el sobre, la completa.
	# El QuestManager se encargará automáticamente de activar "report_envelope".
	if gs.quest and gs.quest.is_current("deliver_mysterious_envelope"):
		gs.quest.complete("deliver_mysterious_envelope")
		
	# El resto del código no cambia.
	gs.set_interaction_enabled(true)
	gs.set_ana_movement(true)

# Esta función no necesita cambios.
func _on_dialogue_end_generico() -> void:
	gs.set_interaction_enabled(true)
	gs.set_ana_movement(true)
