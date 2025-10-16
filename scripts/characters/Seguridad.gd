extends Node2D

@onready var interact: Area2D = $Interact
@onready var gs: Node = get_tree().root.get_node("GameState")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite_Seguridad

func _ready() -> void:
	if animated_sprite:
		# Asumo que 'idle_up' es la animación por defecto
		animated_sprite.play("idle_up") 
	
	if interact and interact.has_signal("interact"):
		interact.connect("interact", Callable(self, "_on_interacted"))
	else:
		push_warning("El nodo $Interact no tiene el signal 'interact'. ¿Tiene asignado Interact.gd?")

func _on_interacted(_player: Node) -> void:
	# Bloquear si ya hay un diálogo activo
	if gs.is_dialog_active:
		return

	var dialogue_timeline = "Seguridad-generico" # Diálogo genérico por defecto
	
	var current_quest = ""
	if gs.quest.has_method("current_id"):
		current_quest = gs.quest.current_id() 

	# 1. Verificar si la misión actual es M6: deliver_mysterious_envelope
	if current_quest == "deliver_mysterious_envelope":
		dialogue_timeline = "Seguridad-deliver_mysterious_envelope"
		# Usamos un callback específico para esta misión, ya que avanza la historia
		gs.play_timeline(dialogue_timeline, Callable(self, "_on_dialogue_end_deliver_envelope"))
	else:
		# Si no es la misión activa, reproduce el genérico
		gs.play_timeline(dialogue_timeline, Callable(self, "_on_dialogue_end_generico"))

	# Bloquear movimiento e interacción de Ana mientras el diálogo está activo
	gs.set_interaction_enabled(false)
	gs.set_ana_movement(false)

# Callback para la finalización del diálogo de entrega del sobre (M6 -> M7)
func _on_dialogue_end_deliver_envelope() -> void:
	# 1. Completar la misión actual (M6: deliver_mysterious_envelope)
	if gs and gs.quest.has_method("complete"):
		gs.quest.complete("deliver_mysterious_envelope")
		
	# 2. Añadir y activar la siguiente misión (M7: report_envelope)
	if gs and gs.quest.has_method("add_objective"):
		gs.quest.add_objective("report_envelope", "Reportar al Jefe la entrega del sobre")

	# Restaurar interacción y movimiento de Ana después del diálogo
	gs.set_interaction_enabled(true)
	gs.set_ana_movement(true)

# Callback genérico para diálogos que no avanzan la misión
func _on_dialogue_end_generico() -> void:
	# Restaurar interacción y movimiento de Ana después del diálogo
	gs.set_interaction_enabled(true)
	gs.set_ana_movement(true)
