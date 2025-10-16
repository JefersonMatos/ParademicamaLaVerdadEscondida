# NivelOficina.gd (Corregido y Optimizado)
extends Node2D

@onready var gs: Node = get_tree().root.get_node("GameState")
@onready var carla: Node2D = $Carla 

func _ready() -> void:
	if gs and gs.quest and gs.quest.has_signal("objective_changed"):
		gs.quest.connect("objective_changed", _on_objective_changed)
	
	var current_quest_id = gs.quest.current_id() if gs and gs.quest else ""
	_update_carla_state(current_quest_id)

func _on_objective_changed(id: String, _text: String, _index: int, _total: int) -> void:
	_update_carla_state(id)

# Lógica para decidir el estado de Carla
func _update_carla_state(quest_id: String) -> void:
	if not carla: return

	# En esta escena, Carla debe estar activa EXCEPTO cuando la misión es 'observe_proof_2'.
	var should_be_active = (quest_id != "observe_proof_2")
	
	# Llamamos a la función auxiliar para aplicar los cambios
	_set_character_active(carla, should_be_active)

# Función auxiliar para controlar visibilidad y colisión (igual que en la otra escena)
func _set_character_active(character_node: Node2D, is_active: bool) -> void:
	if not character_node:
		return

	# Control de Visibilidad
	character_node.visible = is_active

	# Control de Colisión Física (StaticBody2D)
	var static_body = character_node.get_node_or_null("StaticBody2D")
	if static_body:
		static_body.set_deferred("disabled", not is_active)
		
	# Control de Área de Interacción (Area2D)
	var interact_area = character_node.get_node_or_null("Interact")
	if interact_area:
		interact_area.monitoring = is_active
