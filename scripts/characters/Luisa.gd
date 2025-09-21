extends Node2D

@onready var interact: Area2D = $Interact
@onready var gs: Node = get_tree().root.get_node("GameState")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite_Luisa # Asumiendo que el nodo de animación se llama 'AnimatedSprite'

func _ready() -> void:
	# Asegurarse de que la animación 'idle_down' se establece al comenzar
	if animated_sprite:
		animated_sprite.play("idle_down")  # Inicia la animación de idle_down por defecto
	
	# Conectar la señal de interacción
	if interact and interact.has_signal("interact"):
		interact.connect("interact", Callable(self, "_on_interacted"))
	else:
		push_warning("El nodo $Interact no tiene el signal 'interact'. ¿Tiene asignado Interact.gd?")

func _on_interacted(_player: Node) -> void:
	# Bloquear si ya hay un diálogo activo
	if gs.is_dialog_active:
		return

	# Verificar si la misión "Busca a Luisa" está activa
	if gs.quest.is_current("find_luisa"):
		# Reproducir el diálogo de introducción de Luisa
		gs.play_timeline("DialogoLuisaIntroduccion", Callable(self, "_on_dialogue_end"))
	else:
		# Si la misión ya se completó, reproducir el diálogo genérico
		gs.play_timeline("DialogoLuisaGenerico", Callable(self, "_on_dialogue_end"))

	# Bloquear movimiento e interacción de Ana mientras el diálogo está activo
	gs.set_interaction_enabled(false)
	gs.set_ana_movement(false)

# Callback para cuando el diálogo termina
func _on_dialogue_end() -> void:
	# Si la misión "Busca a Luisa" está activa, completarla
	if gs.quest.is_current("find_luisa"):
		gs.quest.call("complete", "find_luisa")  # Completar la misión
		gs.quest.call("add_objective", "explore_office", "Explora las instalaciones y habla con los trabajadores")  # Cambiar de misión

	# Restaurar interacción y movimiento de Ana después del diálogo
	gs.set_interaction_enabled(true)
	gs.set_ana_movement(true)
