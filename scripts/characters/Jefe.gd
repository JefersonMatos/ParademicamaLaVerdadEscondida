extends CharacterBody2D

@onready var interact: Area2D = $Interact
@onready var gs: Node = get_tree().root.get_node("GameState")

func _ready() -> void:
	interact.connect("interacted", Callable(self, "_on_interacted"))

func _on_interacted(_player: Node) -> void:
	# Oculta el prompt de HUD
	if gs and gs.has_method("hud_hide_interact"):
		gs.call("hud_hide_interact")

	# Lanza el timeline y, al terminar, cambia el objetivo a "buscar a Luisa"
	# Opción A: no estaba en la secuencia -> lo agregamos y completamos el actual
	gs.play_timeline("DialogoJefeBienvenida", func ():
		# agrega el siguiente objetivo y completa el actual
		if gs.has_method("quest_add_next"):
			gs.call("quest_add_next", "find_luisa", "BUSCA A LUISA")
		if gs.has_method("quest_complete"):
			gs.call("quest_complete", "talk_boss")
	)
