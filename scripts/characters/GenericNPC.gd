# GenericNPC.gd
extends Node2D

## ⚙️ CONFIGURACIÓN EN EL INSPECTOR ⚙️
@export var dialogues: Array[String] = []
#  Escribe el nombre de la animación para este NPC aquí
@export var animation_name: String = "idle" # Puedes poner un nombre por defecto

@onready var gs: Node = get_tree().root.get_node("GameState")
@onready var interact_area: Area2D = $Interact
# Referencia al nodo de animación
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D # Asume que tu nodo se llama así

# Para llevar la cuenta de qué diálogo toca
var _current_dialogue_index: int = 0

func _ready() -> void:
	# Conectarse a la señal del Area2D (que usa Interact.gd)
	if interact_area and interact_area.has_signal("interact"):
		interact_area.connect("interact", Callable(self, "_on_interacted"))
	else:
		push_warning("Este NPC no tiene un nodo 'Interact' con 'Interact.gd' asignado.")

	# Lógica para reproducir la animación
	if animated_sprite:
		# Comprueba si el nombre de la animación no está vacío
		# Y si esa animación existe en el SpriteFrames
		if animation_name != "" and animated_sprite.sprite_frames.has_animation(animation_name):
			animated_sprite.play(animation_name)
		else:
			push_warning("NPC no pudo reproducir la animación: '" + animation_name + "' no existe.")
	else:
		push_warning("Este NPC no tiene un nodo hijo llamado 'AnimatedSprite2D'.")

func _on_interacted(_player: Node) -> void:
	if gs.is_dialog_active:
		return
	
	if dialogues.is_empty():
		return

	var dialogue_timeline = dialogues[_current_dialogue_index]

	gs.play_timeline(dialogue_timeline, Callable(self, "_on_dialogue_end"))
	gs.set_interaction_enabled(false)
	gs.set_ana_movement(false)
	
	_current_dialogue_index = (_current_dialogue_index + 1) % dialogues.size()

func _on_dialogue_end() -> void:
	gs.set_interaction_enabled(true)
	gs.set_ana_movement(true)
