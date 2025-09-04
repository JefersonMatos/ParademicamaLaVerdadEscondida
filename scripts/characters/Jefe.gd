extends CharacterBody2D # (o Node2D si tu nodo raíz no es CharacterBody2D)

@onready var interact: Area2D = $Interact
@onready var gs: Node = get_tree().root.get_node("GameState")

func _ready() -> void:
	if interact and interact.has_signal("interact"):
		interact.connect("interact", Callable(self, "_on_interacted"))
	else:
		push_warning("El nodo $Interact no tiene el signal 'interact'. ¿Tiene asignado Interact.gd?")

func _on_interacted(_player: Node) -> void:
	if gs and gs.has_method("hud_hide_interact"):
		gs.call("hud_hide_interact")

	gs.play_timeline("DialogoJefeBienvenida", func ():
		if gs.has_method("quest_add_next"):
			gs.call("quest_add_next", "find_luisa", "BUSCA A LUISA")
		if gs.has_method("quest_complete"):
			gs.call("quest_complete", "talk_boss")
	)
