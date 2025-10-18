# SalaVigilancia.gd
extends Node2D

@onready var gs: Node = get_tree().root.get_node("GameState")
@onready var sergio: Node2D = $Seguridad
@onready var interact_camaras: Area2D = $Interact_Camaras

# --- CORRECCIÓN ---
# Lista de misiones donde Sergio SÍ debe estar INVISIBLE (en la oficina del jefe)
const SERGIO_INVISIBLE_MISSIONS = ["extract_proof_4", "meet_miguel_again"]
# --- FIN DE CORRECCIÓN ---

func _ready() -> void:
	# Conectar a la señal de cambio de misión
	if gs and gs.quest and gs.quest.has_signal("objective_changed"):
		gs.quest.connect("objective_changed", _on_objective_changed)
	
	if interact_camaras and interact_camaras.has_signal("interact"):
		interact_camaras.connect("interact", Callable(self, "_on_Interact_Camaras_interacted"))
	else:
		push_warning("El nodo $Interact_Camaras no está asignado o no tiene el script 'Interact.gd'.")
	
	# Revisar estado inicial al cargar la escena
	var current_quest_id = gs.quest.current_id() if gs and gs.quest else ""
	_update_sergio_state(current_quest_id)

func _on_objective_changed(id: String, _text: String, _index: int, _total: int) -> void:
	_update_sergio_state(id)

func _update_sergio_state(quest_id: String) -> void:
	if not sergio: return

	# --- CORRECCIÓN ---
	# Sergio debe estar ACTIVO (visible) si la misión NO está 
	# en la lista de misiones donde él está invisible.
	var should_sergio_be_active = not (quest_id in SERGIO_INVISIBLE_MISSIONS)
	# --- FIN DE CORRECCIÓN ---
	
	_set_character_active(sergio, should_sergio_be_active)

	# --- LÓGICA DE CÁMARAS AÑADIDA ---
	# El área de las cámaras SÓLO debe ser interactiva
	# si Sergio NO está presente (es decir, cuando 'should_sergio_be_active' es false).
	if interact_camaras:
		interact_camaras.monitoring = not should_sergio_be_active
		# Opcional: puedes ocultar el '!' de interacción si Sergio está
		# interact_camaras.visible = not should_sergio_be_active


# Función auxiliar para controlar visibilidad y colisión de SERGIO
func _set_character_active(character_node: Node2D, is_active: bool) -> void:
	if not character_node: return
	character_node.visible = is_active
	
	# Desactivar colisión física (Asume StaticBody2D)
	var static_body = character_node.get_node_or_null("StaticBody2D")
	if static_body:
		for shape in static_body.get_children():
			if shape is CollisionShape2D:
				shape.set_deferred("disabled", not is_active)
		
	# Desactivar área de interacción (Asume Interact)
	var interact_area = character_node.get_node_or_null("Interact")
	if interact_area:
		interact_area.monitoring = is_active

# --- FUNCIONES PARA INTERACT_CAMARAS (Sin cambios) ---
# Se llama cuando Ana interactúa con el monitor de cámaras
func _on_Interact_Camaras_interacted(_player: Node) -> void:
	if gs.is_dialog_active:
		return

	var dialogue_timeline = ""
	var callback_function = null

	# Verificamos la lógica:
	if gs.quest and gs.quest.is_current("extract_proof_4"):
		# Misión activa: Iniciar descarga (Prueba 4)
		dialogue_timeline = "Ana-extract_proof_4"
		callback_function = Callable(self, "_on_dialogue_end_extract_proof_4")
	else:
		# Misión no activa: Diálogo genérico
		# (Nota: Esta rama ahora es casi imposible de alcanzar si 
		# 'monitoring' está bien configurado, pero es un buen respaldo).
		dialogue_timeline = "Camaras-generico"
		callback_function = Callable(self, "_on_dialogue_end_generic_camaras")

	gs.play_timeline(dialogue_timeline, callback_function)
	gs.set_interaction_enabled(false)
	gs.set_ana_movement(false)

# Callback para cuando termina el diálogo de DESCARGA (Misión 17)
func _on_dialogue_end_extract_proof_4() -> void:
	if gs.quest and gs.quest.is_current("extract_proof_4"):
		gs.quest.complete("extract_proof_4")
		# Aquí deberías añadir la prueba al inventario
		# Ejemplo: gs.add_evidence("prueba_4_usb")
	
	gs.set_interaction_enabled(true)
	gs.set_ana_movement(true)

# Callback para el diálogo genérico de las cámaras
func _on_dialogue_end_generic_camaras() -> void:
	gs.set_interaction_enabled(true)
	gs.set_ana_movement(true)
