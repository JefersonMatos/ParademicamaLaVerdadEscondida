extends Node2D

# Asegúrate de que todas tus referencias @onready estén correctas.
@onready var interact_pc: Area2D = $Interact_PC
@onready var gs: Node = get_tree().root.get_node("GameState")
@onready var carla: Node2D = $Carla
@onready var jefe_node: Node2D = $Jefe

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
	if not carla or not jefe_node: return
	
	# En esta escena, Carla SOLO está activa DURANTE 'observe_proof_2'.
	var should_be_active = (quest_id == "observe_proof_2")
	_set_character_active(carla, should_be_active)
	
	if should_be_active:
		var carla_sprite = carla.get_node_or_null("AnimatedSprite_Carla")
		if carla_sprite: carla_sprite.play("idle_right")
		var jefe_sprite = jefe_node.get_node_or_null("AnimatedSprite_Jefe")
		if jefe_sprite: jefe_sprite.play("idle_left")

# La misma función agresiva para desactivar todas las colisiones.
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
