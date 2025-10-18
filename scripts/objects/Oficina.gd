extends Node2D

@onready var gs: Node = get_tree().root.get_node("GameState")
@onready var carla: Node2D = $Carla 
@onready var door_collision_shape: CollisionShape2D = $CambioEscena_Oficina_OficinaJefe/cambioescena_oficina_oficinajefe

# Lista de misiones donde Carla está invisible en ESTA escena
const CARLA_INVISIBLE_MISSIONS = ["observe_proof_2", "go_to_janitor", "search_proof_3", "talk_to_miguel", "wait_for_opportunity"]
# Lista de misiones donde la PUERTA a la oficina del jefe está BLOQUEADA
const DOOR_BLOCKED_MISSIONS = ["go_to_janitor", "search_proof_3", "talk_to_miguel"]

func _ready() -> void:
	if gs and gs.quest and gs.quest.has_signal("objective_changed"):
		gs.quest.connect("objective_changed", _on_objective_changed)
	
	var current_quest_id = gs.quest.current_id() if gs and gs.quest else ""
	_update_scene_state(current_quest_id) # Llama a la función que actualiza todo

func _on_objective_changed(id: String, _text: String, _index: int, _total: int) -> void:
	_update_scene_state(id)

func _update_scene_state(quest_id: String) -> void:
	# --- Lógica de Carla ---
	if carla: 
		var should_carla_be_active = not (quest_id in CARLA_INVISIBLE_MISSIONS)
		_set_character_active(carla, should_carla_be_active)

	# --- Lógica de la Puerta ---
	if door_collision_shape:
		# La puerta está bloqueada (su colisión deshabilitada) si la misión está en la lista.
		var should_door_be_blocked = (quest_id in DOOR_BLOCKED_MISSIONS)
		door_collision_shape.set_deferred("disabled", should_door_be_blocked)
		# print("DEBUG: Puerta bloqueada: ", should_door_be_blocked) # Debugging opcional

# La función para activar/desactivar personajes no cambia
func _set_character_active(character_node: Node2D, is_active: bool) -> void:
	if not character_node: return
	character_node.visible = is_active
	
	var static_body = character_node.get_node_or_null("StaticBody2D")
	if static_body:
		for shape in static_body.get_children():
			if shape is CollisionShape2D:
				shape.set_deferred("disabled", not is_active)
		
	var interact_area = character_node.get_node_or_null("Interact")
	if interact_area:
		interact_area.monitoring = is_active
