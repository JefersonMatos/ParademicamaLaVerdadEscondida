extends Node2D

@onready var interact_pc: Area2D = $Interact_PC # Interactuador de la PC
@onready var gs: Node = get_tree().root.get_node("GameState")
@onready var carla: Node2D = $Carla # Referencia a la instancia de Carla
@onready var jefe_node: Node2D = $Jefe # Referencia a la instancia del Jefe

func _ready() -> void:
	# Conexión del interactuador de la PC (código existente)
	if interact_pc and interact_pc.has_signal("interact"):
		interact_pc.connect("interact", Callable(self, "_on_interacted"))
	else:
		push_warning("El nodo $Interact_PC no tiene el signal 'interact'. ¿Tiene asignado Interact.gd?")
	
	# Conectar a la señal de cambio de objetivo para manejar la Misión 11
	if gs and gs.quest:
		if gs.quest.has_signal("objective_changed"):
			gs.quest.connect("objective_changed", Callable(self, "_on_objective_changed"))
		
		# Verificar el estado inicial al cargar la escena
		var current_id = gs.quest.current_id()
		_update_mission_11_state(current_id)
		
	# Estado inicial: Carla debe estar inactiva (oculta y sin colisión) por defecto.
	_set_character_active(carla, false)


# Función auxiliar para controlar visibilidad y colisión
func _set_character_active(character_node: Node2D, active: bool) -> void:
	if not character_node:
		return

	# Control de Visibilidad (oculta todo el nodo)
	character_node.visible = active

	# Control de Colisión (IMPORTANTE: Esto deshabilita la interacción)
	# Asumimos que el Area2D/CharacterBody2D del personaje tiene un CollisionShape2D hijo,
	# y que el script del personaje tiene un Area2D para la interacción (que tiene un CollisionShape2D).
	
	# Opción 1: Desactivar el Area2D de interacción del personaje
	var interact_area = character_node.get_node_or_null("Interact") 
	if interact_area and interact_area is Area2D:
		interact_area.monitoring = active # Para que Ana detecte la interacción
		interact_area.monitorable = active # Para que el personaje no detecte a Ana (si fuera el caso)
		
	# Opción 2: Desactivar las colisiones del CharacterBody2D si lo tiene
	# Si Carla es un CharacterBody2D, deshabilita su colisión.
	if character_node.has_method("set_collision_mask_value"):
		character_node.set_collision_mask_value(1, active) # Ejemplo, ajusta el layer/mask según tu configuración

# Función llamada cada vez que la misión activa cambia
func _on_objective_changed(id: String, _text: String, _index: int, _total: int) -> void:
	_update_mission_11_state(id)

# Lógica principal para controlar la Misión 11 (observe_proof_2)
func _update_mission_11_state(current_quest_id: String) -> void:
	var is_mision_11_active = (current_quest_id == "observe_proof_2")
	
	# 1. VISIBILIDAD y COLISIÓN DE CARLA
	# Solo activamos a Carla (visible y con colisión) si M11 está activa.
	_set_character_active(carla, is_mision_11_active)
	
	# 2. ANIMACIONES y POSICIONAMIENTO para la escena de conversación
	if is_mision_11_active:
		# Establece las animaciones específicas para el diálogo a tres
		
		# ANIMACIÓN CARLA
		var carla_sprite = carla.get_node_or_null("AnimatedSprite_Carla")
		_set_character_active(carla, true)
		if carla_sprite:
			carla_sprite.play("idle_right")
			
		# ANIMACIÓN JEFE
		var jefe_sprite = jefe_node.get_node_or_null("AnimatedSprite_Jefe")
		if jefe_sprite:
			jefe_sprite.play("idle_left")

# --- Lógica de interacción con la PC (permanece igual) ---

func _on_interacted(_player: Node) -> void:
	if gs.is_dialog_active:
		return

	var current_quest = ""
	if gs.quest.has_method("current_id"):
		current_quest = gs.quest.current_id()

	# Misión M8: search_proof_1 (o cualquier otra lógica de la PC)
	if current_quest == "search_proof_1":
		gs.play_timeline("Ana-search_proof_1", Callable(self, "_on_dialogue_end_search"))
	
	# Misión M11: observe_proof_2 (Bloquea la PC durante la conversación)
	elif current_quest == "observe_proof_2":
		gs.play_timeline("PC-generico", Callable(self, "_on_dialogue_end_generico"))
	
	# Misión NO activa (Genérico)
	else:
		gs.play_timeline("PC-generico", Callable(self, "_on_dialogue_end_generico"))

	gs.set_interaction_enabled(false)
	gs.set_ana_movement(false)

func _on_dialogue_end_search() -> void:
	# M8 a M9: 'search_proof_1' a 'report_agenda'
	if gs and gs.quest.has_method("complete"):
		gs.quest.complete("search_proof_1")
	if gs and gs.quest.has_method("add_objective"):
		gs.quest.add_objective("report_agenda", "Avisa al jefe que terminaste de ordenar su agenda del mes")

	gs.set_interaction_enabled(true)
	gs.set_ana_movement(true)

func _on_dialogue_end_generico() -> void:
	gs.set_interaction_enabled(true)
	gs.set_ana_movement(true)
