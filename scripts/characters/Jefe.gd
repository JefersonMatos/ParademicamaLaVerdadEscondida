extends Node2D

@onready var interact: Area2D = $Interact
@onready var gs: Node = get_tree().root.get_node("GameState")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite_Jefe

var _last_branch: String = ""

func _ready() -> void:
	if animated_sprite:
		animated_sprite.play("idle_down")
	if interact and interact.has_signal("interact"):
		interact.connect("interact", Callable(self, "_on_interacted"))
	else:
		push_warning("El nodo $Interact no tiene el signal 'interact'. ¿Tiene asignado Interact.gd?")

func _on_interacted(_player: Node) -> void:
	if gs.is_dialog_active:
		return

	# La lógica de interacción no necesita cambios, ya está bien estructurada.
	if gs.quest and gs.quest.is_current("report_agenda"):
		_last_branch = "report_agenda"
		gs.play_timeline("Jefe-report_agenda", Callable(self, "_on_dialogue_end"))
	elif gs.quest and gs.quest.is_current("report_envelope"):
		_last_branch = "report_envelope"
		gs.play_timeline("Jefe-report_envelope", Callable(self, "_on_dialogue_end"))
	elif gs.quest and gs.quest.is_current("ask_boss"):
		_last_branch = "ask_boss"
		gs.play_timeline("Jefe-ask_boss", Callable(self, "_on_dialogue_end"))
	else:
		if gs.jefe_dialogue_completed:
			_last_branch = "ocupado"
			gs.play_timeline("DialogoJefeOcupado", Callable(self, "_on_dialogue_end"))
		else:
			_last_branch = "bienvenida"
			gs.play_timeline("DialogoJefeBienvenida", Callable(self, "_on_dialogue_end"))

	gs.set_interaction_enabled(false)
	gs.set_ana_movement(false)

func _on_dialogue_end() -> void:
	match _last_branch:
		"bienvenida":
			# M2 a M3: 'talk_boss' a 'find_luisa'
			if not gs.jefe_dialogue_completed:
				if gs.quest and gs.quest.has_method("add_next"):
					gs.quest.add_next("find_luisa", "Busca a Luisa")
				if gs.quest and gs.quest.has_method("complete"):
					gs.quest.complete("talk_boss")
				gs.jefe_dialogue_completed = true

		"ask_boss":
			# M5 a M6: 'ask_boss' a 'deliver_mysterious_envelope'
			if gs.quest and gs.quest.has_method("add_next"):
				gs.quest.add_next("deliver_mysterious_envelope", "Entrega el SOBRE MISTERIOSO a Sergio")
			if gs.quest and gs.quest.has_method("complete"):
				gs.quest.complete("ask_boss")

		"report_envelope":
			# M7 a M8: 'report_envelope' a 'search_proof_1'
			if gs.quest and gs.quest.has_method("add_next"):
				gs.quest.add_next("search_proof_1", "Accede a la computadora del jefe para organizar su agenda")
			if gs.quest and gs.quest.has_method("complete"):
				gs.quest.complete("report_envelope")
		
		"report_agenda":
			# M9 a M10: 'report_agenda' a 'find_carla'
			if gs.quest and gs.quest.has_method("add_next"):
				gs.quest.add_next("find_carla", "Ve a buscar a Carla y pídele que venga a la oficina del jefe")
			if gs.quest and gs.quest.has_method("complete"):
				gs.quest.complete("report_agenda")
		
		"ocupado", _:
			pass

	gs.set_interaction_enabled(true)
	gs.set_ana_movement(true)
	_last_branch = ""
