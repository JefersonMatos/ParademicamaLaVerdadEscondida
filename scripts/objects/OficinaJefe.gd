# NivelOficinaJefe.gd
extends Node2D

@onready var interact_pc: Area2D = $Interact_PC
@onready var gs: Node = get_tree().root.get_node("GameState")
@onready var carla: Node2D = $Carla
@onready var jefe_node: Node2D = $Jefe
@onready var seguridad: Node2D = $Seguridad 

# Lista de misiones donde Carla SÍ debe estar en esta escena.
const CARLA_VISIBLE_MISSIONS = ["observe_proof_2", "go_to_janitor", "search_proof_3", "talk_to_miguel"]

# Lista de misiones donde Sergio SÍ debe estar en esta escena.
const SERGIO_VISIBLE_MISSIONS = ["extract_proof_4", "meet_miguel_again"]

func _ready() -> void:
	if interact_pc and interact_pc.has_signal("interact"):
		interact_pc.connect("interact", Callable(self, "_on_interacted"))
	
	if gs and gs.quest and gs.quest.has_signal("objective_changed"):
		gs.quest.connect("objective_changed", _on_objective_changed)
	
	var current_quest_id = gs.quest.current_id() if gs and gs.quest else ""
	_update_scene_state(current_quest_id)

func _on_objective_changed(id: String, _text: String, _index: int, _total: int) -> void:
	_update_scene_state(id)

func _update_scene_state(quest_id: String) -> void:
	if not carla or not jefe_node or not seguridad: 
		push_warning("NivelOficinaJefe: Faltan nodos de personaje (Carla, Jefe o Seguridad).")
		return

	# --- 1. Lógica de Visibilidad ---
	
	# Lógica de Carla (se mantiene):
	var carla_should_be_active = (quest_id in CARLA_VISIBLE_MISSIONS)
	_set_character_active(carla, carla_should_be_active)
	
	# Sergio estará activo (visible) si la misión SÍ está en su lista de visibilidad.
	var sergio_should_be_active = (quest_id in SERGIO_VISIBLE_MISSIONS)
	# --- FIN DE CORRECCIÓN ---
	_set_character_active(seguridad, sergio_should_be_active)

	# --- 2. Lógica de Animación (Refactorizada) ---
	
	var jefe_sprite = jefe_node.get_node_or_null("AnimatedSprite_Jefe")
	var carla_sprite = carla.get_node_or_null("AnimatedSprite_Carla")
	var seguridad_sprite = seguridad.get_node_or_null("AnimatedSprite_Seguridad")

	if sergio_should_be_active:
		# Estado: Misiones 'extract_proof_4' o 'meet_miguel_again'.
		# Jefe y Sergio están reunidos.
		if jefe_sprite: jefe_sprite.play("idle_right")
		if seguridad_sprite: seguridad_sprite.play("idle_left")
		
	elif carla_should_be_active:
		# Estado: Misiones de Carla ('observe_proof_2', etc.)
		# Jefe y Carla están reunidos.
		if jefe_sprite: jefe_sprite.play("idle_left")
		if carla_sprite: carla_sprite.play("idle_right")
		
	else:
		# Estado: Default. Ni Carla ni Sergio están. (Jefe solo)
		if jefe_sprite: jefe_sprite.play("idle_down") # O la animación default que prefieras


# La función auxiliar no necesita cambios.
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
		
# --- Lógica de la PC (Sin cambios) ---
func _on_interacted(_player: Node) -> void:
	if gs.is_dialog_active: return
	if gs.quest and gs.quest.is_current("search_proof_1"):
		gs.play_timeline("Ana-search_proof_1", Callable(self, "_on_dialogue_end_search"))
	else:
		gs.play_timeline("PC-generico", Callable(self, "_on_dialogue_end_generico"))
	gs.set_interaction_enabled(false)
	gs.set_ana_movement(false)
func _on_dialogue_end_search() -> void:
	if gs.quest and gs.quest.is_current("search_proof_1"):
		gs.quest.complete("search_proof_1")
	gs.set_interaction_enabled(true)
	gs.set_ana_movement(true)
func _on_dialogue_end_generico() -> void:
	gs.set_interaction_enabled(true)
	gs.set_ana_movement(true)
